// Stub file for conditional imports
import 'package:sqflite/sqflite.dart';

Future<Database> openDatabase(
  String path, {
  int? version,
  Function(Database, int)? onCreate,
  Function(Database, int, int)? onUpgrade,
  bool? singleInstance,
}) {
  throw UnsupportedError('Database not supported on this platform');
}

Future<String> getDatabasesPath() async {
  throw UnsupportedError('Database path not supported on this platform');
}

