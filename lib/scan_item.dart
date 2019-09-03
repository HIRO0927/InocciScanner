import 'package:flutter_mobile_vision/flutter_mobile_vision.dart';

class ScanItem {
  int id;
  String text;

  static const String columnId = "id";
  static const String columnText = "text";

  ScanItem.fromMap(Map map) {
    id = map[columnId];
    text = map[columnText];
  }

  ScanItem.fromBarcode(Barcode barcode) {
    text = barcode.displayValue;
  }

  Map<String, dynamic> toMap() {
    Map<String, dynamic> map = {columnText: text};
    if (id != null) {
      map[columnId] = id;
    }
    return map;
  }
}