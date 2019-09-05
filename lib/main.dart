import 'dart:async';

import 'package:flutter/material.dart';
import 'package:barcode_scan/barcode_scan.dart';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';

import 'package:qr_scanner_app1/database.dart';
import 'package:qr_scanner_app1/scan_item.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false, //右上のバナー消すやつ
  home: HomePage(),
  routes: <String, WidgetBuilder>{'zaiko': (_) => Zaiko()},
));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class Zaiko extends StatefulWidget {
  @override
  ZaikoState createState() {
    return ZaikoState();
  }
}

class ZaikoState extends State<Zaiko> {
  List<ScanItem> _items = [];  //スキャンアイテムのリスト箱

  @override
  void initState() { //最初の表示
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    String path = await getDatabaseFilePath("zaiko_history.db");
    Database db = await openReadOnlyDatabase(path);

    List<Map> data = await db.query("zaiko_hisoty", columns: ["text"]); //Map化する

    List<ScanItem> items = [];
    data.forEach((e) => items.add(ScanItem.fromMap(e)));

    setState(() {
      _items = items;
    });

    await db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("残りの在庫"),
        ),
        body: new ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text("${_items[index].name}"));
            }));
  }
}

class HomePageState extends State<HomePage> {
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
              Navigator.of(context).pushNamed("zaiko");
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