/**
 * Centralized Providers
 * 
 * All Riverpod providers for the application.
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database.dart';
import 'database_provider.dart';

// Search query provider for invoices
final invoiceSearchProvider = StateProvider<String>((ref) => '');

// Filtered invoices provider
final filteredInvoicesProvider = StreamProvider<List<Invoice>>((ref) {
  final database = ref.watch(databaseProvider);
  final searchQuery = ref.watch(invoiceSearchProvider).toLowerCase();

  return database.watchAllInvoices().map((invoices) {
    if (searchQuery.isEmpty) return invoices;

    return invoices.where((invoice) {
      return invoice.invoiceNumber.toLowerCase().contains(searchQuery) ||
          invoice.customerName.toLowerCase().contains(searchQuery);
    }).toList();
  });
});
