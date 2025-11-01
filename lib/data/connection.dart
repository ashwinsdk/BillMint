import 'package:drift/drift.dart';

export 'connection/unsupported.dart'
    if (dart.library.js_interop) 'connection/web.dart'
    if (dart.library.io) 'connection/native.dart';

DatabaseConnection connect() {
  return createDatabaseConnection();
}
