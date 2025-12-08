// Database implementation for mobile (iOS/Android) and desktop
import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Export Database type for consistency
export 'package:sqflite/sqflite.dart' show Database;

Future<sqflite.Database> openDatabase(
  String path, {
  int? version,
  Function(sqflite.Database, int)? onCreate,
  Function(sqflite.Database, int, int)? onUpgrade,
  bool? singleInstance,
}) async {
  // Initialize sqflite_common_ffi for desktop platforms
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  return sqflite.openDatabase(
    path,
    version: version,
    onCreate: onCreate,
    onUpgrade: onUpgrade,
    singleInstance: singleInstance ?? false,
  );
}

Future<String> getDatabasesPath() async {
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    // For desktop, use application documents directory
    final directory = await getApplicationDocumentsDirectory();
    return join(directory.path, 'databases');
  } else {
    // For mobile, use sqflite's default path
    return sqflite.getDatabasesPath();
  }
}
