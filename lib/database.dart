import 'dart:async';
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

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