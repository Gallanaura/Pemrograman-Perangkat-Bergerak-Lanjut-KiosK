// Database implementation for web - not supported
// Web platform requires additional setup that is complex
// For now, we'll show a clear error message
import 'package:sqflite/sqflite.dart' as sqflite;

// Export Database type for consistency
export 'package:sqflite/sqflite.dart' show Database;

Future<sqflite.Database> openDatabase(
  String path, {
  int? version,
  Function(sqflite.Database, int)? onCreate,
  Function(sqflite.Database, int, int)? onUpgrade,
  bool? singleInstance,
}) async {
  throw UnsupportedError(
    'Database is not supported on web platform.\n\n'
    'Please use the mobile (iOS/Android) or desktop (Windows/macOS/Linux) version of the app.\n\n'
    'For web support, you would need to:\n'
    '1. Set up sqflite_common_ffi_web with worker files\n'
    '2. Or use an alternative database like sembast or hive for web'
  );
}

Future<String> getDatabasesPath() async {
  throw UnsupportedError('Database path not supported on web platform');
}
