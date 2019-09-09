import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';


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
      '/stock': (context) => Stock(),
      }
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  String result = "Hey sup bro?"; //初期ホーム画面文言

  Future _scanQR() async {
    try {
      String qrResult = await BarcodeScanner.scan(); //qrResultにスキャン結果わたす
      setState(() {
        result = qrResult;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inocci Scanner"), //appbar title name
        actions: <Widget>[
          FlatButton(
            child: Text('残りの在庫'),
            textColor: Color(0xFFFFFFFF),
            onPressed: () {
              Navigator.of(context).pushNamed("/stock");
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          result, //条件分岐による結果を表示
          style: new TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: Icon(Icons.camera_alt),
        label: Text("Scan"),
        onPressed: _scanQR,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}

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

    ByteData data = await rootBundle.load(join("assets", "database.db")); //アセット内に格納した外付けDB
    List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    await new File(path).writeAsBytes(bytes);

    Database db = await openDatabase(path); //アプリのSQLiteファイルのworking_data.dbを開く

    List<Map> resultMap = await db.rawQuery('SELECT * FROM shoes'); //SQLコマンドで全てのデータ呼び出し

    for (Map item in resultMap) { //必要なデータを表示
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
}