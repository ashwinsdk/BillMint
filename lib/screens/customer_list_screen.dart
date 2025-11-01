import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../providers/database_provider.dart';

class CustomerListScreen extends ConsumerStatefulWidget {
  const CustomerListScreen({super.key});

  @override
  ConsumerState<CustomerListScreen> createState() => _CustomerListScreenState();
}

class _CustomerListScreenState extends ConsumerState<CustomerListScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final database = ref.watch(databaseProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customers'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search customers...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.toLowerCase();
                });
              },
            ),
          ),
        ),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: database.watchAllCustomers(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final customers = snapshot.data ?? [];
          final filteredCustomers = customers.where((customer) {
            if (_searchQuery.isEmpty) return true;
            return customer.name.toLowerCase().contains(_searchQuery) ||
                (customer.phone?.toLowerCase().contains(_searchQuery) ??
                    false) ||
                (customer.email?.toLowerCase().contains(_searchQuery) ?? false);
          }).toList();

          if (filteredCustomers.isEmpty) {
            return const Center(
              child: Text('No customers found.\nTap + to add a customer.'),
            );
          }

          return ListView.builder(
            itemCount: filteredCustomers.length,
            itemBuilder: (context, index) {
              final customer = filteredCustomers[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(customer.name[0].toUpperCase()),
                ),
                title: Text(customer.name),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (customer.phone != null) Text(customer.phone!),
                    if (customer.email != null) Text(customer.email!),
                  ],
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteCustomer(customer),
                ),
                onTap: () => _editCustomer(customer),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCustomer,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addCustomer() async {
    final database = ref.read(databaseProvider);
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final emailController = TextEditingController();
    final addressController = TextEditingController();
    final gstinController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
                autofocus: true,
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextField(
                controller: gstinController,
                decoration: const InputDecoration(labelText: 'GSTIN'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final now = DateTime.now();
      await database.insertCustomer(
        CustomersCompanion.insert(
          id: 'cust_${now.millisecondsSinceEpoch}',
          name: nameController.text,
          phone: phoneController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(phoneController.text),
          email: emailController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(emailController.text),
          address: addressController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(addressController.text),
          gstin: gstinController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(gstinController.text),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  Future<void> _editCustomer(Customer customer) async {
    final database = ref.read(databaseProvider);
    final nameController = TextEditingController(text: customer.name);
    final phoneController = TextEditingController(text: customer.phone ?? '');
    final emailController = TextEditingController(text: customer.email ?? '');
    final addressController = TextEditingController(
      text: customer.address ?? '',
    );
    final gstinController = TextEditingController(text: customer.gstin ?? '');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Customer'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
                maxLines: 2,
              ),
              TextField(
                controller: gstinController,
                decoration: const InputDecoration(labelText: 'GSTIN'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result == true && nameController.text.isNotEmpty) {
      final updated = customer.copyWith(
        name: nameController.text,
        phone: drift.Value(
          phoneController.text.isEmpty ? null : phoneController.text,
        ),
        email: drift.Value(
          emailController.text.isEmpty ? null : emailController.text,
        ),
        address: drift.Value(
          addressController.text.isEmpty ? null : addressController.text,
        ),
        gstin: drift.Value(
          gstinController.text.isEmpty ? null : gstinController.text,
        ),
        updatedAt: DateTime.now(),
      );
      await database.updateCustomer(updated);
    }
  }

  Future<void> _deleteCustomer(Customer customer) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Customer'),
        content: Text('Are you sure you want to delete ${customer.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (result == true) {
      final database = ref.read(databaseProvider);
      await database.deleteCustomer(customer.id);
    }
  }
}
