/**
 * Invoice Detail Screen
 * 
 * Displays invoice preview and generates PDF e-bill
 */

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
import '../providers/database_provider.dart';

class InvoiceDetailScreen extends ConsumerStatefulWidget {
  final Invoice invoice;

  const InvoiceDetailScreen({super.key, required this.invoice});

  @override
  ConsumerState<InvoiceDetailScreen> createState() =>
      _InvoiceDetailScreenState();
}

class _InvoiceDetailScreenState extends ConsumerState<InvoiceDetailScreen> {
  List<InvoiceItem> _items = [];
  Map<String, String> _businessSettings = {};
  bool _isLoading = true;

  // Recalculate correct total (subtotal - discount)
  // Items already include GST in their prices
  double get _correctTotal => widget.invoice.subtotal - widget.invoice.discount;

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  Future<void> _loadInvoiceData() async {
    final database = ref.read(databaseProvider);

    // Load invoice items
    final items = await database.getInvoiceItems(widget.invoice.id);

    // Load business settings
    final settings = {
      'businessName':
          await database.getSetting('businessName') ?? 'Your Business',
      'businessAddress': await database.getSetting('businessAddress') ?? '',
      'businessPhone': await database.getSetting('businessPhone') ?? '',
      'businessEmail': await database.getSetting('businessEmail') ?? '',
      'gstin': await database.getSetting('gstin') ?? '',
      'upiId': await database.getSetting('upiId') ?? '',
    };

    setState(() {
      _items = items;
      _businessSettings = settings;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Invoice Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.invoice.invoiceNumber),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareInvoice,
            tooltip: 'Share',
          ),
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _saveInvoice,
            tooltip: 'Save to Files',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: _buildInvoicePreview(),
      ),
    );
  }

  Widget _buildInvoicePreview() {
    final dateFormat = DateFormat('dd MMM yyyy');
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Business Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _businessSettings['businessName'] ?? 'Your Business',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (_businessSettings['businessAddress']!.isNotEmpty)
                        Text(_businessSettings['businessAddress']!),
                      if (_businessSettings['businessPhone']!.isNotEmpty)
                        Text('Phone: ${_businessSettings['businessPhone']}'),
                      if (_businessSettings['businessEmail']!.isNotEmpty)
                        Text('Email: ${_businessSettings['businessEmail']}'),
                      if (_businessSettings['gstin']!.isNotEmpty)
                        Text('GSTIN: ${_businessSettings['gstin']}'),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 32, thickness: 2),

            // Invoice Title
            const Center(
              child: Text(
                'TAX INVOICE',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Invoice Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Invoice No: ${widget.invoice.invoiceNumber}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Date: ${dateFormat.format(widget.invoice.invoiceDate)}',
                    ),
                    if (widget.invoice.dueDate != null)
                      Text(
                        'Due Date: ${dateFormat.format(widget.invoice.dueDate!)}',
                      ),
                    if (widget.invoice.paymentTerms != null)
                      Text(
                        'Terms: ${widget.invoice.paymentTerms}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                  ],
                ),
                _buildPaymentStatusBadge(),
              ],
            ),
            const SizedBox(height: 16),

            // Payment Action Buttons
            if (widget.invoice.paymentStatus != 'paid')
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _markAsPaid,
                      icon: const Icon(Icons.payment),
                      label: const Text('Mark as Paid'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  ),
                  if (widget.invoice.paymentStatus == 'unpaid')
                    const SizedBox(width: 8),
                  if (widget.invoice.paymentStatus == 'unpaid')
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _recordPartialPayment,
                        icon: const Icon(Icons.payments),
                        label: const Text('Partial Payment'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.orange,
                        ),
                      ),
                    ),
                ],
              ),
            const SizedBox(height: 24),

            // Customer Details
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bill To:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.invoice.customerName,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (widget.invoice.customerPhone != null)
                    Text(widget.invoice.customerPhone!),
                  if (widget.invoice.customerAddress != null)
                    Text(widget.invoice.customerAddress!),
                  if (widget.invoice.customerGstin != null)
                    Text('GSTIN: ${widget.invoice.customerGstin}'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Items Table
            Table(
              border: TableBorder.all(color: Colors.grey.shade300),
              columnWidths: const {
                0: FlexColumnWidth(0.5),
                1: FlexColumnWidth(2),
                2: FlexColumnWidth(1),
                3: FlexColumnWidth(1),
                4: FlexColumnWidth(1),
                5: FlexColumnWidth(1),
              },
              children: [
                // Header
                TableRow(
                  decoration: BoxDecoration(color: Colors.grey.shade200),
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        '#',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Item',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'HSN',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Qty',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Rate',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(
                        'Amount',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                // Items
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return TableRow(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${index + 1}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.name),
                            Text(
                              'GST ${item.gstRate}%',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(item.hsnCode ?? '-'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text('${item.quantity} ${item.unit}'),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(currencyFormat.format(item.price)),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(currencyFormat.format(item.amount)),
                      ),
                    ],
                  );
                }),
              ],
            ),
            const SizedBox(height: 24),

            // Totals
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  width: 300,
                  child: Column(
                    children: [
                      _buildTotalRow('Subtotal:', widget.invoice.subtotal),
                      if (widget.invoice.discount > 0)
                        _buildTotalRow('Discount:', -widget.invoice.discount),
                      _buildTotalRow(
                        'Taxable Value:',
                        widget.invoice.taxableValue,
                      ),
                      _buildTotalRow('CGST:', widget.invoice.cgst),
                      _buildTotalRow('SGST:', widget.invoice.sgst),
                      if (widget.invoice.igst > 0)
                        _buildTotalRow('IGST:', widget.invoice.igst),
                      const Divider(thickness: 2),
                      _buildTotalRow(
                        'Total:',
                        _correctTotal,
                        isBold: true,
                        fontSize: 18,
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (widget.invoice.notes != null &&
                widget.invoice.notes!.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text(
                'Notes:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(widget.invoice.notes!),
            ],

            // Footer
            const SizedBox(height: 32),
            if (_businessSettings['upiId']!.isNotEmpty) ...[
              const Text(
                'Payment Info:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('UPI ID: ${_businessSettings['upiId']}'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    double fontSize = 14,
  }) {
    final currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 2);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
          Text(
            currencyFormat.format(amount),
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatusBadge() {
    Color bgColor;
    Color textColor;
    String label;

    switch (widget.invoice.paymentStatus) {
      case 'paid':
        bgColor = Colors.green.shade100;
        textColor = Colors.green.shade800;
        label = 'PAID';
        break;
      case 'partial':
        bgColor = Colors.orange.shade100;
        textColor = Colors.orange.shade800;
        final paid = widget.invoice.paidAmount;
        final total = _correctTotal;
        label =
            'PARTIAL\n₹${paid.toStringAsFixed(0)}/₹${total.toStringAsFixed(0)}';
        break;
      default: // 'unpaid'
        bgColor = Colors.red.shade100;
        textColor = Colors.red.shade800;
        label = 'UNPAID';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }

  Future<void> _markAsPaid() async {
    final database = ref.read(databaseProvider);

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mark as Paid'),
        content: Text(
          'Mark invoice ${widget.invoice.invoiceNumber} as fully paid?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Mark as Paid'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      // Create a companion object with the updated values
      final updatedInvoice = InvoicesCompanion(
        id: drift.Value(widget.invoice.id),
        paymentStatus: const drift.Value('paid'),
        paidAmount: drift.Value(_correctTotal),
        paymentDate: drift.Value(DateTime.now()),
      );

      // Update using the database update method
      await (database.update(
        database.invoices,
      )..where((t) => t.id.equals(widget.invoice.id))).write(updatedInvoice);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Invoice marked as paid')));
        Navigator.pop(context); // Return to previous screen
      }
    }
  }

  Future<void> _recordPartialPayment() async {
    final database = ref.read(databaseProvider);
    final amountController = TextEditingController();

    final amount = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Record Partial Payment'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Total: ₹${_correctTotal.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Payment Amount',
                prefixText: '₹ ',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = double.tryParse(amountController.text);
              if (value != null && value > 0 && value < _correctTotal) {
                Navigator.pop(context, value);
              }
            },
            child: const Text('Record'),
          ),
        ],
      ),
    );

    if (amount != null) {
      final newPaidAmount = widget.invoice.paidAmount + amount;
      final newStatus = newPaidAmount >= _correctTotal ? 'paid' : 'partial';

      // Create a companion object with the updated values
      final updatedInvoice = InvoicesCompanion(
        id: drift.Value(widget.invoice.id),
        paymentStatus: drift.Value(newStatus),
        paidAmount: drift.Value(newPaidAmount),
        paymentDate: drift.Value(DateTime.now()),
      );

      // Update using the database update method
      await (database.update(
        database.invoices,
      )..where((t) => t.id.equals(widget.invoice.id))).write(updatedInvoice);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Recorded payment of ₹${amount.toStringAsFixed(2)}'),
          ),
        );
        Navigator.pop(context); // Return to previous screen
      }
    }
  }

  Future<void> _shareInvoice() async {
    try {
      final pdfData = await _generatePdf();
      final directory = await getTemporaryDirectory();
      final file = File(
        '${directory.path}/${widget.invoice.invoiceNumber}.pdf',
      );
      await file.writeAsBytes(pdfData);

      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice ${widget.invoice.invoiceNumber}',
        text: 'Please find attached invoice ${widget.invoice.invoiceNumber}',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error sharing invoice: $e')));
      }
    }
  }

  Future<void> _saveInvoice() async {
    try {
      final pdfData = await _generatePdf();
      final directory = await getApplicationDocumentsDirectory();
      final file = File(
        '${directory.path}/${widget.invoice.invoiceNumber}.pdf',
      );
      await file.writeAsBytes(pdfData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Invoice saved to ${file.path}'),
            action: SnackBarAction(
              label: 'Share',
              onPressed: () => _shareInvoice(),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving invoice: $e')));
      }
    }
  }

  Future<Uint8List> _generatePdf() async {
    final pdf = pw.Document();
    final dateFormat = DateFormat('dd MMM yyyy');

    // Load logo if exists (optional)
    pw.ImageProvider? logo;
    try {
      final logoData = await rootBundle.load('assets/logo.png');
      logo = pw.MemoryImage(logoData.buffer.asUint8List());
    } catch (e) {
      // Logo not found, continue without it
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(20),
        build: (pw.Context context) {
          return [
            // Header with logo
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      _businessSettings['businessName'] ?? 'Your Business',
                      style: pw.TextStyle(
                        fontSize: 18,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    if (_businessSettings['businessAddress']!.isNotEmpty)
                      pw.Text(
                        _businessSettings['businessAddress']!,
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    if (_businessSettings['businessPhone']!.isNotEmpty)
                      pw.Text(
                        'Phone: ${_businessSettings['businessPhone']}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    if (_businessSettings['businessEmail']!.isNotEmpty)
                      pw.Text(
                        'Email: ${_businessSettings['businessEmail']}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    if (_businessSettings['gstin']!.isNotEmpty)
                      pw.Text(
                        'GSTIN: ${_businessSettings['gstin']}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                  ],
                ),
                if (logo != null)
                  pw.Container(width: 60, height: 60, child: pw.Image(logo)),
              ],
            ),
            pw.Divider(thickness: 1.5),
            pw.SizedBox(height: 8),

            // Invoice Title
            pw.Center(
              child: pw.Text(
                'TAX INVOICE',
                style: pw.TextStyle(
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            pw.SizedBox(height: 8),

            // Invoice Details
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Invoice No: ${widget.invoice.invoiceNumber}',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                    pw.Text(
                      'Date: ${dateFormat.format(widget.invoice.invoiceDate)}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                    if (widget.invoice.dueDate != null)
                      pw.Text(
                        'Due Date: ${dateFormat.format(widget.invoice.dueDate!)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    if (widget.invoice.paymentTerms != null)
                      pw.Text(
                        'Terms: ${widget.invoice.paymentTerms}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColors.grey200,
                        borderRadius: pw.BorderRadius.circular(4),
                        border: pw.Border.all(
                          color: PdfColors.black,
                          width: 1.5,
                        ),
                      ),
                      child: pw.Text(
                        widget.invoice.paymentStatus == 'paid'
                            ? 'PAID'
                            : widget.invoice.paymentStatus == 'partial'
                            ? 'PARTIAL PAYMENT'
                            : 'UNPAID',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                    if (widget.invoice.paymentStatus == 'partial') ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Paid: Rs. ${widget.invoice.paidAmount.toStringAsFixed(2)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                    if (widget.invoice.paymentDate != null) ...[
                      pw.SizedBox(height: 4),
                      pw.Text(
                        'Payment Date: ${dateFormat.format(widget.invoice.paymentDate!)}',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ],
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 8),

            // Customer Details
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Bill To:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                  pw.SizedBox(height: 2),
                  pw.Text(
                    widget.invoice.customerName,
                    style: const pw.TextStyle(fontSize: 10),
                  ),
                  if (widget.invoice.customerPhone != null)
                    pw.Text(
                      widget.invoice.customerPhone!,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  if (widget.invoice.customerAddress != null)
                    pw.Text(
                      widget.invoice.customerAddress!,
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                  if (widget.invoice.customerGstin != null)
                    pw.Text(
                      'GSTIN: ${widget.invoice.customerGstin}',
                      style: const pw.TextStyle(fontSize: 9),
                    ),
                ],
              ),
            ),
            pw.SizedBox(height: 8),

            // Items Table
            pw.Table(
              border: pw.TableBorder.all(color: PdfColors.black, width: 1),
              columnWidths: {
                0: const pw.FixedColumnWidth(25),
                1: const pw.FlexColumnWidth(3),
                2: const pw.FixedColumnWidth(55),
                3: const pw.FixedColumnWidth(50),
                4: const pw.FixedColumnWidth(65),
                5: const pw.FixedColumnWidth(75),
              },
              children: [
                // Header
                pw.TableRow(
                  decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                  children: [
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        '#',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'HSN',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Rate',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                    pw.Padding(
                      padding: const pw.EdgeInsets.all(5),
                      child: pw.Text(
                        'Amount',
                        style: pw.TextStyle(
                          fontWeight: pw.FontWeight.bold,
                          fontSize: 9,
                        ),
                        textAlign: pw.TextAlign.right,
                      ),
                    ),
                  ],
                ),
                // Items
                ..._items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return pw.TableRow(
                    decoration: pw.BoxDecoration(
                      color: index % 2 == 0
                          ? PdfColors.grey100
                          : PdfColors.white,
                    ),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '${index + 1}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              item.name,
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 9,
                              ),
                            ),
                            pw.SizedBox(height: 1),
                            pw.Text(
                              'GST ${item.gstRate}%',
                              style: const pw.TextStyle(
                                fontSize: 8,
                                color: PdfColors.grey700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          item.hsnCode ?? '-',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          '${item.quantity} ${item.unit}',
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Rs. ${item.price.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: const pw.TextStyle(fontSize: 9),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(5),
                        child: pw.Text(
                          'Rs. ${item.amount.toStringAsFixed(2)}',
                          textAlign: pw.TextAlign.right,
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 9,
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 8),

            // Totals
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Container(
                  width: 260,
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey800, width: 1),
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Column(
                    children: [
                      _buildPdfTotalRow('Subtotal:', widget.invoice.subtotal),
                      if (widget.invoice.discount > 0)
                        _buildPdfTotalRow(
                          'Discount:',
                          -widget.invoice.discount,
                        ),
                      pw.Divider(thickness: 0.5, color: PdfColors.grey400),
                      _buildPdfTotalRow(
                        'Taxable Value:',
                        widget.invoice.taxableValue,
                      ),
                      _buildPdfTotalRow('CGST:', widget.invoice.cgst),
                      _buildPdfTotalRow('SGST:', widget.invoice.sgst),
                      if (widget.invoice.igst > 0)
                        _buildPdfTotalRow('IGST:', widget.invoice.igst),
                      pw.Container(
                        color: PdfColors.grey300,
                        padding: const pw.EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        child: pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                          children: [
                            pw.Text(
                              'Total:',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                            pw.Text(
                              'Rs. ${_correctTotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Notes
            if (widget.invoice.notes != null &&
                widget.invoice.notes!.isNotEmpty) ...[
              pw.SizedBox(height: 8),
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Notes:',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      widget.invoice.notes!,
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
            ],

            // Terms & Conditions
            pw.SizedBox(height: 8),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400),
                borderRadius: pw.BorderRadius.circular(4),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Terms & Conditions:',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 9,
                    ),
                  ),
                  pw.SizedBox(height: 3),
                  pw.Text(
                    '1. Payment is due within the specified payment terms.',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    '2. Please make the payment to the provided bank account or UPI ID.',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    '3. Goods once sold will not be taken back or exchanged.',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                  pw.Text(
                    '4. All disputes subject to local jurisdiction only.',
                    style: const pw.TextStyle(fontSize: 8),
                  ),
                ],
              ),
            ),

            // Footer
            pw.SizedBox(height: 8),
            if (_businessSettings['upiId']!.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'Payment Info',
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 9,
                      ),
                    ),
                    pw.SizedBox(height: 2),
                    pw.Text(
                      'UPI ID: ${_businessSettings['upiId']}',
                      style: const pw.TextStyle(fontSize: 8),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 8),
            ],
            pw.Center(
              child: pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
            pw.SizedBox(height: 12),
            pw.Divider(thickness: 0.5),
            pw.SizedBox(height: 4),
            pw.Center(
              child: pw.Text(
                'Powered by BillMint - Professional Invoice & Billing Management',
                style: pw.TextStyle(fontSize: 8, color: PdfColors.grey700),
              ),
            ),
          ];
        },
        footer: (context) => pw.Container(
          alignment: pw.Alignment.centerRight,
          margin: const pw.EdgeInsets.only(top: 8),
          child: pw.Text(
            'Page ${context.pageNumber} of ${context.pagesCount}',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ),
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildPdfTotalRow(
    String label,
    double amount, {
    bool isBold = false,
    PdfColor? textColor,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: textColor,
              fontSize: 9,
            ),
          ),
          pw.Text(
            'Rs. ${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontWeight: isBold ? pw.FontWeight.bold : pw.FontWeight.normal,
              color: textColor,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}
