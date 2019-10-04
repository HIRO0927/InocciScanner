import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';


void main() {
  runApp(new MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        debugShowCheckedModeBanner: false, //右上のバナー消すやつ
        title: 'InocciScan',
        initialRoute: '/',
        routes: {
          '/': (context) => HomePage(),
        }
    );
  }
}

class HomePage extends StatefulWidget {

  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => new _HomePageState();

}

class _HomePageState extends State<HomePage> {

  List<Widget> _items = <Widget>[];  //リスト_itemsを定義

  @override
  void initState() { //最初の表示
    super.initState();
    getItems();
  }

  void getItems() async {
    List<Widget> list = <Widget>[];
    Directory databaseDirectory = await getApplicationDocumentsDirectory(); //パス作成
    String path = join(databaseDirectory.path, "working_data.db"); //アプリ表示用DB作成
    Database db = await openDatabase(path); //アプリのSQLiteファイルのworking_data.dbを開く

    ByteData data = await rootBundle.load(join("assets", "database.db")); //アセット内に格納した外付けDB
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes); //working_data.dbにassets/database.dbを代入

    List<Map> resultMap = await db.rawQuery('SELECT * FROM shoes'); //SQLコマンドで全てのデータ呼び出し

    for (Map item in resultMap) {
      //必要なデータを表示
      list.add(
          ListTile(
            title: Text(item['name']),
            subtitle: Text('(' + item['id'].toString() + ')  ' + item['code']),
          )
      );
    }

    setState(() {
      _items = list; //_itemsにlist(必要なデータ)引き渡し
    });
  }

  Future _deleteScanItem() async {
    List<Widget> list = <Widget>[];
    String scan = await BarcodeScanner.scan();

    String path = await getDatabaseFilePath("working_data.db");
    Database db = await openDatabase(path);

    List<Map> resultMap = await db.rawQuery('SELECT * FROM shoes'); //SQLコマンドで全てのデータ呼び出し

    await db.transaction((t) async {
      await t.execute('DELETE FROM shoes WHERE code = "$scan"');
    });


    for (Map item in resultMap) {
      //必要なデータを表示
      list.add(
          ListTile(
            title: Text(item['name']),
            subtitle: Text('(' + item['id'].toString() + ')  ' + item['code']),
          )
      );
    }

    setState(() {
      _items = list; //_itemsにlist(必要なデータ)引き渡し
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inocci Scanner"), //appbar title name
      ),
      body: ListView(
        children: _items,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: () {
          _deleteScanItem();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

Future<String> getDatabaseFilePath(String dbName) async {
  Directory documentsDirectory = await getApplicationDocumentsDirectory();
  print(documentsDirectory);

  String path = join(documentsDirectory.path, dbName);

  if (await new Directory(dirname(path)).exists()) {
    return path;
  }

  try {
    await new Directory(dirname(path)).create(recursive: true);
  } catch (e) {
    print(e);
  }
  return path;
}
