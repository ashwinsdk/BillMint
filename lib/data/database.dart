/**
 * Database schema definition using Drift
 * 
 * This file defines the database tables for BillMint:
 * - Customers: Store customer information
 * - Products: Store product catalog with HSN and GST rates
 * - Invoices: Store invoice records with computed totals
 * - InvoiceItems: Store individual items in each invoice
 * - AppSettings: Store app configuration
 */

import 'package:drift/drift.dart';
import 'connection.dart' as connection;

part 'database.g.dart';

// Customer table
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get gstin => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Product table
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get description => text().nullable()();
  TextColumn get hsnCode => text().nullable()();
  TextColumn get unit => text().withDefault(const Constant('pcs'))();
  RealColumn get price => real()();
  RealColumn get gstRate => real().withDefault(const Constant(0))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Invoice table
class Invoices extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceNumber => text().unique()();
  TextColumn get customerId => text()();
  TextColumn get customerName => text()();
  TextColumn get customerPhone => text().nullable()();
  TextColumn get customerAddress => text().nullable()();
  TextColumn get customerGstin => text().nullable()();
  DateTimeColumn get invoiceDate => dateTime()();
  DateTimeColumn get dueDate => dateTime().nullable()();
  RealColumn get subtotal => real()();
  RealColumn get discount => real().withDefault(const Constant(0))();
  RealColumn get taxableValue => real()();
  RealColumn get cgst => real().withDefault(const Constant(0))();
  RealColumn get sgst => real().withDefault(const Constant(0))();
  RealColumn get igst => real().withDefault(const Constant(0))();
  RealColumn get total => real()();
  TextColumn get notes => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// Invoice items table
class InvoiceItems extends Table {
  TextColumn get id => text()();
  TextColumn get invoiceId => text()();
  TextColumn get productId => text()();
  TextColumn get name => text()();
  TextColumn get hsnCode => text().nullable()();
  IntColumn get quantity => integer()();
  TextColumn get unit => text()();
  RealColumn get price => real()();
  RealColumn get gstRate => real()();
  RealColumn get amount => real()();
  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

// App settings table
class AppSettings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {key};
}

@DriftDatabase(
  tables: [Customers, Products, Invoices, InvoiceItems, AppSettings],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(connection.connect());

  @override
  int get schemaVersion => 1;

  // Customer queries
  Future<List<Customer>> getAllCustomers() => select(customers).get();

  Stream<List<Customer>> watchAllCustomers() => select(customers).watch();

  Future<Customer?> getCustomerById(String id) =>
      (select(customers)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Customer>> searchCustomers(String query) =>
      (select(customers)
            ..where((t) => t.name.like('%$query%') | t.phone.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<int> insertCustomer(CustomersCompanion customer) =>
      into(customers).insert(customer);

  Future<bool> updateCustomer(Customer customer) =>
      update(customers).replace(customer);

  Future<int> deleteCustomer(String id) =>
      (delete(customers)..where((t) => t.id.equals(id))).go();

  // Product queries
  Future<List<Product>> getAllProducts() => select(products).get();

  Stream<List<Product>> watchAllProducts() => select(products).watch();

  Future<Product?> getProductById(String id) =>
      (select(products)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Product>> searchProducts(String query) =>
      (select(products)
            ..where((t) => t.name.like('%$query%'))
            ..orderBy([(t) => OrderingTerm.asc(t.name)]))
          .get();

  Future<int> insertProduct(ProductsCompanion product) =>
      into(products).insert(product);

  Future<bool> updateProduct(Product product) =>
      update(products).replace(product);

  Future<int> deleteProduct(String id) =>
      (delete(products)..where((t) => t.id.equals(id))).go();

  // Invoice queries
  Future<List<Invoice>> getAllInvoices({int? limit, int? offset}) {
    final query = select(invoices)
      ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]);

    if (limit != null) query.limit(limit, offset: offset);

    return query.get();
  }

  Stream<List<Invoice>> watchAllInvoices() => (select(
    invoices,
  )..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)])).watch();

  Future<Invoice?> getInvoiceById(String id) =>
      (select(invoices)..where((t) => t.id.equals(id))).getSingleOrNull();

  Future<List<Invoice>> searchInvoices(String query) =>
      (select(invoices)
            ..where(
              (t) =>
                  t.invoiceNumber.like('%$query%') |
                  t.customerName.like('%$query%'),
            )
            ..orderBy([(t) => OrderingTerm.desc(t.invoiceDate)]))
          .get();

  Future<int> insertInvoice(InvoicesCompanion invoice) =>
      into(invoices).insert(invoice);

  Future<bool> updateInvoice(Invoice invoice) =>
      update(invoices).replace(invoice);

  Future<int> deleteInvoice(String id) =>
      (delete(invoices)..where((t) => t.id.equals(id))).go();

  // Invoice items queries
  Future<List<InvoiceItem>> getInvoiceItems(String invoiceId) =>
      (select(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).get();

  Future<int> insertInvoiceItem(InvoiceItemsCompanion item) =>
      into(invoiceItems).insert(item);

  Future<int> deleteInvoiceItems(String invoiceId) =>
      (delete(invoiceItems)..where((t) => t.invoiceId.equals(invoiceId))).go();

  // Settings queries
  Future<String?> getSetting(String key) async {
    final setting = await (select(
      appSettings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return setting?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(appSettings).insertOnConflictUpdate(
      AppSettingsCompanion(
        key: Value(key),
        value: Value(value),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // Batch operations for backup/restore
  Future<void> insertCustomersBatch(
    List<CustomersCompanion> customersList,
  ) async {
    await batch((batch) {
      batch.insertAll(
        customers,
        customersList,
        mode: InsertMode.insertOrReplace,
      );
    });
  }

  Future<void> insertProductsBatch(List<ProductsCompanion> productsList) async {
    await batch((batch) {
      batch.insertAll(products, productsList, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> insertInvoicesBatch(List<InvoicesCompanion> invoicesList) async {
    await batch((batch) {
      batch.insertAll(invoices, invoicesList, mode: InsertMode.insertOrReplace);
    });
  }

  Future<void> clearAllData() async {
    await transaction(() async {
      await delete(invoiceItems).go();
      await delete(invoices).go();
      await delete(products).go();
      await delete(customers).go();
    });
  }
}
