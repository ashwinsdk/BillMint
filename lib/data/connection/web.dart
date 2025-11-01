import 'package:drift/drift.dart';
import 'package:drift/web.dart';

DatabaseConnection createDatabaseConnection() {
  return DatabaseConnection(WebDatabase('billmint_db', logStatements: true));
}
