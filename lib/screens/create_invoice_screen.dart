/**
 * Create Invoice Screen
 * 
 * Multi-step invoice creation with customer/product selection
 */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../data/database.dart';
import '../providers/database_provider.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  Customer? _selectedCustomer;
  final List<InvoiceItemData> _items = [];
  DateTime _invoiceDate = DateTime.now();
  DateTime? _dueDate;
  final _notesController = TextEditingController();
  double _discount = 0.0;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  double get _subtotal => _items.fold(0, (sum, item) => sum + item.amount);
  double get _taxableValue => _subtotal - _discount;
  double get _totalGST => _items.fold(0, (sum, item) {
    final itemTaxable = item.amount * (100 / (100 + item.gstRate));
    return sum + (item.amount - itemTaxable);
  });
  double get _total =>
      _taxableValue + (_taxableValue * 0); // GST already in price

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _canSaveInvoice() ? _saveInvoice : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 80, // Space for FAB
              ),
              children: [
                _buildCustomerSection(),
                const SizedBox(height: 16),
                _buildDateSection(),
                const SizedBox(height: 16),
                _buildItemsSection(),
                const SizedBox(height: 16),
                _buildDiscountSection(),
                const SizedBox(height: 16),
                _buildNotesSection(),
                const SizedBox(height: 16),
              ],
            ),
          ),
          _buildTotalSection(),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addItem,
        icon: const Icon(Icons.add),
        label: const Text('Add Item'),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildCustomerSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.person),
        title: Text(_selectedCustomer?.name ?? 'Select Customer'),
        subtitle: _selectedCustomer != null
            ? Text(_selectedCustomer!.phone ?? 'No phone')
            : const Text('Tap to select customer'),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: _selectCustomer,
      ),
    );
  }

  Widget _buildDateSection() {
    final dateFormat = DateFormat('dd MMM yyyy');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Invoice Date'),
              subtitle: Text(dateFormat.format(_invoiceDate)),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _invoiceDate,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _invoiceDate = date);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.event),
              title: const Text('Due Date (Optional)'),
              subtitle: Text(
                _dueDate != null ? dateFormat.format(_dueDate!) : 'Not set',
              ),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate:
                      _dueDate ?? _invoiceDate.add(const Duration(days: 30)),
                  firstDate: _invoiceDate,
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  setState(() => _dueDate = date);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection() {
    return Card(
      child: Column(
        children: [
          const ListTile(
            leading: Icon(Icons.shopping_cart),
            title: Text('Items', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          if (_items.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text('No items added yet\nTap + to add items'),
            )
          else
            ..._items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              return ListTile(
                title: Text(item.name),
                subtitle: Text(
                  '${item.quantity} ${item.unit} × ₹${item.price.toStringAsFixed(2)}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '₹${item.amount.toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => setState(() => _items.removeAt(index)),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDiscountSection() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.discount),
        title: const Text('Discount'),
        trailing: SizedBox(
          width: 100,
          child: TextField(
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              prefixText: '₹ ',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              setState(() => _discount = double.tryParse(value) ?? 0.0);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          controller: _notesController,
          decoration: const InputDecoration(
            labelText: 'Notes (Optional)',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
      ),
    );
  }

  Widget _buildTotalSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColor.withOpacity(0.1),
        border: Border(top: BorderSide(color: Theme.of(context).dividerColor)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Subtotal:'),
              Text('₹${_subtotal.toStringAsFixed(2)}'),
            ],
          ),
          if (_discount > 0)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discount:'),
                Text('-₹${_discount.toStringAsFixed(2)}'),
              ],
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('GST:'),
              Text('₹${_totalGST.toStringAsFixed(2)}'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                '₹${_total.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _selectCustomer() async {
    final database = ref.read(databaseProvider);
    final customers = await database.getAllCustomers();

    if (!mounted) return;

    final selected = await showDialog<Customer>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Customer'),
        content: SizedBox(
          width: double.maxFinite,
          child: customers.isEmpty
              ? const Text('No customers found. Add customers first.')
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: customers.length,
                  itemBuilder: (context, index) {
                    final customer = customers[index];
                    return ListTile(
                      title: Text(customer.name),
                      subtitle: Text(customer.phone ?? 'No phone'),
                      onTap: () => Navigator.pop(context, customer),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected != null) {
      setState(() => _selectedCustomer = selected);
    }
  }

  Future<void> _addItem() async {
    final database = ref.read(databaseProvider);
    final products = await database.getAllProducts();

    if (!mounted) return;

    if (products.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No products found. Add products first.')),
      );
      return;
    }

    final selected = await showDialog<Product>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Product'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                title: Text(product.name),
                subtitle: Text(
                  '₹${product.price.toStringAsFixed(2)} + ${product.gstRate}% GST',
                ),
                onTap: () => Navigator.pop(context, product),
              );
            },
          ),
        ),
      ),
    );

    if (selected != null && mounted) {
      final quantity = await showDialog<int>(
        context: context,
        builder: (context) {
          final controller = TextEditingController(text: '1');
          return AlertDialog(
            title: const Text('Enter Quantity'),
            content: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantity',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, int.tryParse(controller.text) ?? 1),
                child: const Text('Add'),
              ),
            ],
          );
        },
      );

      if (quantity != null && quantity > 0) {
        setState(() {
          _items.add(
            InvoiceItemData(
              productId: selected.id,
              name: selected.name,
              hsnCode: selected.hsnCode,
              quantity: quantity,
              unit: selected.unit,
              price: selected.price,
              gstRate: selected.gstRate,
              amount: selected.price * quantity,
            ),
          );
        });
      }
    }
  }

  bool _canSaveInvoice() {
    return _selectedCustomer != null && _items.isNotEmpty;
  }

  Future<void> _saveInvoice() async {
    if (!_canSaveInvoice()) return;

    final database = ref.read(databaseProvider);
    final now = DateTime.now();
    final invoiceNumber =
        'INV-${DateFormat('yyyyMMdd').format(now)}-${now.millisecondsSinceEpoch % 10000}';

    try {
      // Insert invoice
      final invoiceId = 'inv_${now.millisecondsSinceEpoch}';
      await database.insertInvoice(
        InvoicesCompanion.insert(
          id: invoiceId,
          invoiceNumber: invoiceNumber,
          customerId: _selectedCustomer!.id,
          customerName: _selectedCustomer!.name,
          customerPhone: drift.Value(_selectedCustomer!.phone),
          customerAddress: drift.Value(_selectedCustomer!.address),
          customerGstin: drift.Value(_selectedCustomer!.gstin),
          invoiceDate: _invoiceDate,
          dueDate: drift.Value(_dueDate),
          subtotal: _subtotal,
          discount: drift.Value(_discount),
          taxableValue: _taxableValue,
          cgst: drift.Value(_totalGST / 2),
          sgst: drift.Value(_totalGST / 2),
          total: _subtotal,
          notes: drift.Value(
            _notesController.text.isEmpty ? null : _notesController.text,
          ),
          createdAt: now,
          updatedAt: now,
        ),
      );

      // Insert invoice items
      for (final item in _items) {
        await database.insertInvoiceItem(
          InvoiceItemsCompanion.insert(
            id: 'item_${now.millisecondsSinceEpoch}_${_items.indexOf(item)}',
            invoiceId: invoiceId,
            productId: item.productId,
            name: item.name,
            hsnCode: drift.Value(item.hsnCode),
            quantity: item.quantity,
            unit: item.unit,
            price: item.price,
            gstRate: item.gstRate,
            amount: item.amount,
            createdAt: now,
          ),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice $invoiceNumber created successfully'),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error creating invoice: $e')));
      }
    }
  }
}

class InvoiceItemData {
  final String productId;
  final String name;
  final String? hsnCode;
  final int quantity;
  final String unit;
  final double price;
  final double gstRate;
  final double amount;

  InvoiceItemData({
    required this.productId,
    required this.name,
    this.hsnCode,
    required this.quantity,
    required this.unit,
    required this.price,
    required this.gstRate,
    required this.amount,
  });
}
