import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';
import 'package:flutterqrscan/database.dart';
import 'package:flutterqrscan/models/scan_item.dart';
import 'package:share/share.dart';
import 'package:sqflite/sqflite.dart';

void main() => runApp(MaterialApp(
  debugShowCheckedModeBanner: false,
  home: HomePage(),
  routes: <String, WidgetBuilder>{'history': (_) => History()},
));

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() {
    return HomePageState();
  }
}

class History extends StatefulWidget {
  @override
  HistoryState createState() {
    return HistoryState();
  }
}

class HistoryState extends State<History> {
  List<ScanItem> _items = [];

  @override
  void initState() {
    super.initState();
    _initDatabase();
  }

  _initDatabase() async {
    String path = await getDatabaseFilePath("scan_history.db");
    Database db = await openReadOnlyDatabase(path);

    List<Map> data = await db.query("scan_hisoty", columns: ["text"]);

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
          title: Text("Scanner History"),
        ),
        body: new ListView.builder(
            itemCount: _items.length,
            itemBuilder: (context, index) {
              return ListTile(title: Text("${_items[index].text}"));
            }));
  }
}

class HomePageState extends State<HomePage> {
  String result = "Hey there !";

  Future _scanQR() async {
    List<Barcode> barcodes = [];
    try {
      barcodes = await FlutterMobileVision.scan(
        flash: false,
        autoFocus: true,
        formats: Barcode.ALL_FORMATS,
        multiple: false,
        showText: true,
        camera: FlutterMobileVision.CAMERA_BACK,
        fps: 30.0,
      );
      setState(() {
        result = barcodes[0].displayValue;
        Share.share(result);
        _insertScanItem(barcodes[0]);
      });
    } on Exception {
      result = 'Failed to get barcode.';
      barcodes.add(new Barcode('Failed to get barcode.'));
    }
  }

  _insertScanItem(Barcode barcode) async {
    String path = await getDatabaseFilePath("scan_history.db");
    Database db = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute(
              "CREATE TABLE scan_hisoty (id INTEGER PRIMARY KEY, text TEXT)");
        });

    await db.transaction((t) async {
      int i =
      await t.insert("scan_hisoty", ScanItem.fromBarcode(barcode).toMap());
      print(i);
    });

    db.close();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("QR Scanner"),
        actions: <Widget>[
          FlatButton(
            child: Text('History'),
            textColor: Color(0xFFFFFFFF),
            onPressed: () {
              Navigator.of(context).pushNamed("history");
            },
          )
        ],
      ),
      body: Center(
        child: Text(
          result,
          style: TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold),
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