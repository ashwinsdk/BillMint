/**
 * API Service for syncing with backend
 * 
 * Provides methods to sync customers, products, invoices, and backups
 * with the BillMint backend REST API.
 */

import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl;

  ApiService({required this.baseUrl});

  // Customer endpoints
  Future<List<dynamic>> getCustomers() async {
    final response = await http.get(Uri.parse('$baseUrl/api/customers'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List;
    }
    throw Exception('Failed to load customers: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createCustomer(
    Map<String, dynamic> customer,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/customers'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to create customer: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateCustomer(
    String id,
    Map<String, dynamic> customer,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/customers/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(customer),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to update customer: ${response.statusCode}');
  }

  Future<void> deleteCustomer(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/customers/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete customer: ${response.statusCode}');
    }
  }

  // Product endpoints
  Future<List<dynamic>> getProducts() async {
    final response = await http.get(Uri.parse('$baseUrl/api/products'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List;
    }
    throw Exception('Failed to load products: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createProduct(
    Map<String, dynamic> product,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/products'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to create product: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateProduct(
    String id,
    Map<String, dynamic> product,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/products/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(product),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to update product: ${response.statusCode}');
  }

  Future<void> deleteProduct(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/products/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete product: ${response.statusCode}');
    }
  }

  // Invoice endpoints
  Future<List<dynamic>> getInvoices({
    int limit = 100,
    int offset = 0,
    String? search,
  }) async {
    var url = '$baseUrl/api/invoices?limit=$limit&offset=$offset';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'] as List;
    }
    throw Exception('Failed to load invoices: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> createInvoice(
    Map<String, dynamic> invoice,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/invoices'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(invoice),
    );
    if (response.statusCode == 201) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to create invoice: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> updateInvoice(
    String id,
    Map<String, dynamic> invoice,
  ) async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/invoices/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(invoice),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to update invoice: ${response.statusCode}');
  }

  Future<void> deleteInvoice(String id) async {
    final response = await http.delete(Uri.parse('$baseUrl/api/invoices/$id'));
    if (response.statusCode != 200) {
      throw Exception('Failed to delete invoice: ${response.statusCode}');
    }
  }

  // Backup endpoints
  Future<Map<String, dynamic>> downloadBackup() async {
    final response = await http.get(Uri.parse('$baseUrl/api/backup'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['data'];
    }
    throw Exception('Failed to download backup: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> uploadBackup(Map<String, dynamic> backup) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/backup'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(backup),
    );
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    }
    throw Exception('Failed to upload backup: ${response.statusCode}');
  }

  // Health check
  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
