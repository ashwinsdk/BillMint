import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../providers/database_provider.dart';

class ProductListScreen extends ConsumerStatefulWidget {
  const ProductListScreen({super.key});

  @override
  ConsumerState<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends ConsumerState<ProductListScreen> {
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
        title: const Text('Products'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search products...',
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
      body: StreamBuilder<List<Product>>(
        stream: database.watchAllProducts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          final filteredProducts = products.where((product) {
            if (_searchQuery.isEmpty) return true;
            return product.name.toLowerCase().contains(_searchQuery) ||
                (product.description?.toLowerCase().contains(_searchQuery) ??
                    false) ||
                (product.hsnCode?.toLowerCase().contains(_searchQuery) ??
                    false);
          }).toList();

          if (filteredProducts.isEmpty) {
            return const Center(
              child: Text('No products found.\nTap + to add a product.'),
            );
          }

          return ListView.builder(
            itemCount: filteredProducts.length,
            itemBuilder: (context, index) {
              final product = filteredProducts[index];
              return ListTile(
                leading: const Icon(Icons.inventory_2),
                title: Text(product.name),
                subtitle: Text(
                  '₹${product.price.toStringAsFixed(2)} | GST: ${product.gstRate}%',
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteProduct(product),
                ),
                onTap: () => _editProduct(product),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addProduct,
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> _addProduct() async {
    final database = ref.read(databaseProvider);
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final hsnController = TextEditingController();
    final unitController = TextEditingController(text: 'PCS');
    final priceController = TextEditingController();
    final gstController = TextEditingController(text: '18');

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Product'),
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
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: hsnController,
                decoration: const InputDecoration(labelText: 'HSN Code'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: gstController,
                decoration: const InputDecoration(labelText: 'GST Rate (%) *'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
      final price = double.tryParse(priceController.text) ?? 0.0;
      final gstRate = double.tryParse(gstController.text) ?? 0.0;
      final now = DateTime.now();

      await database.insertProduct(
        ProductsCompanion.insert(
          id: 'prod_${now.millisecondsSinceEpoch}',
          name: nameController.text,
          description: descController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(descController.text),
          hsnCode: hsnController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(hsnController.text),
          unit: drift.Value(unitController.text),
          price: price,
          gstRate: drift.Value(gstRate),
          createdAt: drift.Value(now),
          updatedAt: drift.Value(now),
        ),
      );
    }
  }

  Future<void> _editProduct(Product product) async {
    final database = ref.read(databaseProvider);
    final nameController = TextEditingController(text: product.name);
    final descController = TextEditingController(
      text: product.description ?? '',
    );
    final hsnController = TextEditingController(text: product.hsnCode ?? '');
    final unitController = TextEditingController(text: product.unit);
    final priceController = TextEditingController(
      text: product.price.toString(),
    );
    final gstController = TextEditingController(
      text: product.gstRate.toString(),
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Product'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name *'),
              ),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
              TextField(
                controller: hsnController,
                decoration: const InputDecoration(labelText: 'HSN Code'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: priceController,
                decoration: const InputDecoration(labelText: 'Price *'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              TextField(
                controller: gstController,
                decoration: const InputDecoration(labelText: 'GST Rate (%) *'),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
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
      final price = double.tryParse(priceController.text) ?? 0.0;
      final gstRate = double.tryParse(gstController.text) ?? 0.0;

      await database.updateProduct(
        ProductsCompanion(
          id: drift.Value(product.id),
          name: drift.Value(nameController.text),
          description: descController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(descController.text),
          hsnCode: hsnController.text.isEmpty
              ? const drift.Value.absent()
              : drift.Value(hsnController.text),
          unit: drift.Value(unitController.text),
          price: drift.Value(price),
          gstRate: drift.Value(gstRate),
          updatedAt: drift.Value(DateTime.now()),
        ),
      );
    }
  }

  Future<void> _deleteProduct(Product product) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Are you sure you want to delete ${product.name}?'),
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
      await database.deleteProduct(product.id);
    }
  }
}
