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
          //'/stock': (context) => Stock(),
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
/*  String result = "Hey sup bro?"; //初期ホーム画面文言

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan(); //qrResultにスキャン結果わたす
      setState(() {
        result = qrResult;
        Share.share(result);

      });
    } on PlatformException catch (ex) {
      if (ex.code == BarcodeScanner.CameraAccessDenied) {
        setState(() {
          result = "Camera permission was denied";
        });
      } else {
        setState(() {
          result = "Unknown Error $ex";
        });
      }
    } on FormatException {
      setState(() {
        result = "You pressed the back button before scanning anything";
      });
    } catch (ex) {
      setState(() {
        result = "Unknown Error $ex";
      });
    }
  }
*/

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

/*
    Directory databaseDirectory = await getApplicationDocumentsDirectory(); //パス作成
    String path = join(databaseDirectory.path, "working_data.db"); //アプリ表示用DB作成
    Database db = await openDatabase(path);

    ByteData data = await rootBundle.load(join("assets", "database.db")); //アセット内に格納した外付けDB
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes); //working_data.dbにassets/database.dbを代入
*/

    List<Map> resultMap = await db.rawQuery('SELECT * FROM shoes'); //SQLコマンドで全てのデータ呼び出し

    //await db.transaction((t) async {
    //  await t.execute('DELETE FROM shoes WHERE code = "$scan"');
    //});


    for (Map item in resultMap) {
      if (item['code'] != scan) {
        list.add(
            ListTile(
              title: Text(item['name']),
              subtitle: Text('(' + item['id'] + ')  ' + item['code']),
            )
        );
      }

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
        /*
        actions: <Widget>[
          FlatButton(
            child: Text('残りの在庫'),
            textColor: Color(0xFFFFFFFF),
            onPressed: () {
              Navigator.of(context).pushNamed("/stock");
            },
          )
        ],
         */
      ),
      body: ListView(
        children: _items,
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: () {
          //_scanQR();
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


/*
class Stock extends StatefulWidget {

  Stock({Key key}) : super(key: key);

  @override
  _StockState createState() => new _StockState();
}

class _StockState extends State<Stock> {

  List<Widget> _items = <Widget>[];  //リスト_itemsを定義

  @override
  void initState() { //最初の表示
    super.initState();
    getItems();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("残りの在庫"),
        ),
        body: ListView(
          children: _items,
        )
    );
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

    String scan = await BarcodeScanner.scan();
    await db.transaction((t) async {
      await t.rawQuery('DELETE FROM shoes WHERE code = "$scan"');
    });


    setState(() {
      _items = list; //_itemsにlist(必要なデータ)引き渡し
    });
  }
}

class ScanItem {
  int id;
  String name;
  String code;

  static const String columnId = "id";
  static const String columnName = "name";
  static const String columnCode = "code";


  ScanItem.fromMap(Map map) {
    id = map[columnId];
    name = map[columnName];
    code = map[columnCode];
  }

  ScanItem.fromBarcode(BarcodeScanner barcode) {
    name = barcode.toString();
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {columnName: name};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}

// return the path
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
*/