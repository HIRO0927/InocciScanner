import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

//スキャンアイテム定義

class ScanItem {
  int id;
  String name;
  String code;

  static const String columnId = "id";
  static const String columnName = "text";
  static const String columnCode = "code";

  ScanItem.fromMap(Map map) {
    id = map[columnId];
    name = map[columnName];
    code = map[columnCode];
  }

  ScanItem.fromBarcode(Barcode barcode) {
    code = barcode.displayValue;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {columnName: name};
    if (id != null) {
      map[columnName] = name;
    }
    return map;
  }
}