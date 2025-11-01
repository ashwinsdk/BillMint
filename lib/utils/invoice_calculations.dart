/**
 * Invoice calculations and utilities
 * 
 * Pure functions for calculating GST, totals, and invoice numbers.
 * These functions are unit-tested to ensure accuracy.
 */

class InvoiceCalculations {
  /// Calculate GST amount based on taxable value and rate
  static double calculateGst(double taxableValue, double gstRate) {
    return (taxableValue * gstRate) / 100;
  }

  /// Calculate CGST (half of total GST for intra-state)
  static double calculateCgst(double taxableValue, double gstRate) {
    return calculateGst(taxableValue, gstRate) / 2;
  }

  /// Calculate SGST (half of total GST for intra-state)
  static double calculateSgst(double taxableValue, double gstRate) {
    return calculateGst(taxableValue, gstRate) / 2;
  }

  /// Calculate IGST (full GST for inter-state)
  static double calculateIgst(double taxableValue, double gstRate) {
    return calculateGst(taxableValue, gstRate);
  }

  /// Calculate item amount (quantity * price)
  static double calculateItemAmount(int quantity, double price) {
    return quantity * price;
  }

  /// Calculate subtotal from items
  static double calculateSubtotal(List<InvoiceItemData> items) {
    return items.fold(0.0, (sum, item) => sum + item.amount);
  }

  /// Calculate taxable value (subtotal - discount)
  static double calculateTaxableValue(double subtotal, double discount) {
    return subtotal - discount;
  }

  /// Calculate total GST for an invoice
  /// Uses CGST+SGST for intra-state, IGST for inter-state
  static InvoiceGstBreakdown calculateInvoiceGst({
    required List<InvoiceItemData> items,
    required double discount,
    required bool isInterState,
  }) {
    final subtotal = calculateSubtotal(items);
    final taxableValue = calculateTaxableValue(subtotal, discount);

    // Group items by GST rate
    final Map<double, double> taxableByRate = {};
    for (final item in items) {
      final itemTaxable = item.amount * (1 - (discount / subtotal));
      taxableByRate[item.gstRate] =
          (taxableByRate[item.gstRate] ?? 0) + itemTaxable;
    }

    double totalCgst = 0;
    double totalSgst = 0;
    double totalIgst = 0;

    if (isInterState) {
      // Inter-state: Use IGST
      for (final entry in taxableByRate.entries) {
        totalIgst += calculateIgst(entry.value, entry.key);
      }
    } else {
      // Intra-state: Use CGST + SGST
      for (final entry in taxableByRate.entries) {
        totalCgst += calculateCgst(entry.value, entry.key);
        totalSgst += calculateSgst(entry.value, entry.key);
      }
    }

    final total = taxableValue + totalCgst + totalSgst + totalIgst;

    return InvoiceGstBreakdown(
      subtotal: roundToTwo(subtotal),
      discount: roundToTwo(discount),
      taxableValue: roundToTwo(taxableValue),
      cgst: roundToTwo(totalCgst),
      sgst: roundToTwo(totalSgst),
      igst: roundToTwo(totalIgst),
      total: roundToTwo(total),
    );
  }

  /// Calculate final total
  static double calculateTotal({
    required double taxableValue,
    required double cgst,
    required double sgst,
    required double igst,
  }) {
    return taxableValue + cgst + sgst + igst;
  }

  /// Round to 2 decimal places
  static double roundToTwo(double value) {
    return (value * 100).roundToDouble() / 100;
  }

  /// Generate next invoice number based on format
  /// Format: PREFIX-YYYY-NNN
  /// Example: INV-2025-001
  static String generateInvoiceNumber({
    required String prefix,
    required int year,
    required int sequence,
  }) {
    final paddedSequence = sequence.toString().padLeft(3, '0');
    return '$prefix-$year-$paddedSequence';
  }

  /// Parse invoice number to extract sequence
  /// Returns null if format is invalid
  static int? parseInvoiceSequence(String invoiceNumber) {
    final parts = invoiceNumber.split('-');
    if (parts.length != 3) return null;
    return int.tryParse(parts[2]);
  }

  /// Get next invoice number based on last invoice
  static String getNextInvoiceNumber(String? lastInvoiceNumber, String prefix) {
    final now = DateTime.now();
    final year = now.year;

    if (lastInvoiceNumber == null || lastInvoiceNumber.isEmpty) {
      return generateInvoiceNumber(prefix: prefix, year: year, sequence: 1);
    }

    final sequence = parseInvoiceSequence(lastInvoiceNumber);
    if (sequence == null) {
      return generateInvoiceNumber(prefix: prefix, year: year, sequence: 1);
    }

    // Check if year changed, reset sequence if so
    final lastYear = int.tryParse(lastInvoiceNumber.split('-')[1]);
    if (lastYear != null && lastYear != year) {
      return generateInvoiceNumber(prefix: prefix, year: year, sequence: 1);
    }

    return generateInvoiceNumber(
      prefix: prefix,
      year: year,
      sequence: sequence + 1,
    );
  }
}

/// Data class for invoice item
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

/// Data class for GST breakdown
class InvoiceGstBreakdown {
  final double subtotal;
  final double discount;
  final double taxableValue;
  final double cgst;
  final double sgst;
  final double igst;
  final double total;

  InvoiceGstBreakdown({
    required this.subtotal,
    required this.discount,
    required this.taxableValue,
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.total,
  });
}
