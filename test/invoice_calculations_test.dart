import 'package:flutter_test/flutter_test.dart';
import 'package:billmint/utils/invoice_calculations.dart';

void main() {
  group('Invoice Calculations', () {
    test('calculateGst returns correct GST amount', () {
      expect(InvoiceCalculations.calculateGst(100, 18), 18.0);
      expect(InvoiceCalculations.calculateGst(100, 12), 12.0);
      expect(InvoiceCalculations.calculateGst(100, 0), 0.0);
      expect(InvoiceCalculations.calculateGst(50.50, 18), 9.09);
    });

    test('calculateCgst returns half of GST', () {
      expect(InvoiceCalculations.calculateCgst(100, 18), 9.0);
      expect(InvoiceCalculations.calculateCgst(100, 12), 6.0);
    });

    test('calculateSgst returns half of GST', () {
      expect(InvoiceCalculations.calculateSgst(100, 18), 9.0);
      expect(InvoiceCalculations.calculateSgst(100, 12), 6.0);
    });

    test('calculateIgst returns full GST', () {
      expect(InvoiceCalculations.calculateIgst(100, 18), 18.0);
      expect(InvoiceCalculations.calculateIgst(100, 12), 12.0);
    });

    test('calculateItemAmount multiplies quantity and price', () {
      expect(InvoiceCalculations.calculateItemAmount(2, 100), 200.0);
      expect(InvoiceCalculations.calculateItemAmount(5, 50.50), 252.5);
      expect(InvoiceCalculations.calculateItemAmount(1, 99.99), 99.99);
    });

    test('calculateSubtotal sums all item amounts', () {
      final items = [
        InvoiceItemData(
          productId: '1',
          name: 'Item 1',
          quantity: 2,
          unit: 'pcs',
          price: 100,
          gstRate: 18,
          amount: 200,
        ),
        InvoiceItemData(
          productId: '2',
          name: 'Item 2',
          quantity: 3,
          unit: 'pcs',
          price: 50,
          gstRate: 18,
          amount: 150,
        ),
      ];

      expect(InvoiceCalculations.calculateSubtotal(items), 350.0);
    });

    test('calculateTaxableValue subtracts discount from subtotal', () {
      expect(InvoiceCalculations.calculateTaxableValue(1000, 100), 900.0);
      expect(InvoiceCalculations.calculateTaxableValue(500, 0), 500.0);
      expect(InvoiceCalculations.calculateTaxableValue(1000, 50), 950.0);
    });

    test('roundToTwo rounds correctly', () {
      expect(InvoiceCalculations.roundToTwo(10.123), 10.12);
      expect(InvoiceCalculations.roundToTwo(10.125), 10.13);
      expect(InvoiceCalculations.roundToTwo(10.999), 11.0);
      expect(InvoiceCalculations.roundToTwo(10.0), 10.0);
    });

    test('generateInvoiceNumber formats correctly', () {
      expect(
        InvoiceCalculations.generateInvoiceNumber(
          prefix: 'INV',
          year: 2025,
          sequence: 1,
        ),
        'INV-2025-001',
      );

      expect(
        InvoiceCalculations.generateInvoiceNumber(
          prefix: 'INV',
          year: 2025,
          sequence: 123,
        ),
        'INV-2025-123',
      );
    });

    test('parseInvoiceSequence extracts sequence number', () {
      expect(InvoiceCalculations.parseInvoiceSequence('INV-2025-001'), 1);
      expect(InvoiceCalculations.parseInvoiceSequence('INV-2025-123'), 123);
      expect(InvoiceCalculations.parseInvoiceSequence('INVALID'), null);
    });

    test('getNextInvoiceNumber increments sequence', () {
      expect(
        InvoiceCalculations.getNextInvoiceNumber('INV-2025-001', 'INV'),
        'INV-2025-002',
      );

      expect(
        InvoiceCalculations.getNextInvoiceNumber('INV-2025-999', 'INV'),
        'INV-2025-1000',
      );
    });

    test('getNextInvoiceNumber starts at 1 for null', () {
      expect(
        InvoiceCalculations.getNextInvoiceNumber(null, 'INV'),
        contains('001'),
      );
    });

    test('calculateInvoiceGst for intra-state (CGST+SGST)', () {
      final items = [
        InvoiceItemData(
          productId: '1',
          name: 'Item',
          quantity: 1,
          unit: 'pcs',
          price: 100,
          gstRate: 18,
          amount: 100,
        ),
      ];

      final breakdown = InvoiceCalculations.calculateInvoiceGst(
        items: items,
        discount: 0,
        isInterState: false,
      );

      expect(breakdown.subtotal, 100.0);
      expect(breakdown.taxableValue, 100.0);
      expect(breakdown.cgst, 9.0);
      expect(breakdown.sgst, 9.0);
      expect(breakdown.igst, 0.0);
      expect(breakdown.total, 118.0);
    });

    test('calculateInvoiceGst for inter-state (IGST)', () {
      final items = [
        InvoiceItemData(
          productId: '1',
          name: 'Item',
          quantity: 1,
          unit: 'pcs',
          price: 100,
          gstRate: 18,
          amount: 100,
        ),
      ];

      final breakdown = InvoiceCalculations.calculateInvoiceGst(
        items: items,
        discount: 0,
        isInterState: true,
      );

      expect(breakdown.subtotal, 100.0);
      expect(breakdown.taxableValue, 100.0);
      expect(breakdown.cgst, 0.0);
      expect(breakdown.sgst, 0.0);
      expect(breakdown.igst, 18.0);
      expect(breakdown.total, 118.0);
    });

    test('calculateInvoiceGst handles discount correctly', () {
      final items = [
        InvoiceItemData(
          productId: '1',
          name: 'Item',
          quantity: 1,
          unit: 'pcs',
          price: 100,
          gstRate: 18,
          amount: 100,
        ),
      ];

      final breakdown = InvoiceCalculations.calculateInvoiceGst(
        items: items,
        discount: 10,
        isInterState: false,
      );

      expect(breakdown.subtotal, 100.0);
      expect(breakdown.discount, 10.0);
      expect(breakdown.taxableValue, 90.0);
      expect(breakdown.cgst, 8.1);
      expect(breakdown.sgst, 8.1);
      expect(breakdown.total, 106.2);
    });

    test('calculateInvoiceGst handles multiple GST rates', () {
      final items = [
        InvoiceItemData(
          productId: '1',
          name: 'Item 18%',
          quantity: 1,
          unit: 'pcs',
          price: 100,
          gstRate: 18,
          amount: 100,
        ),
        InvoiceItemData(
          productId: '2',
          name: 'Item 12%',
          quantity: 1,
          unit: 'pcs',
          price: 100,
          gstRate: 12,
          amount: 100,
        ),
      ];

      final breakdown = InvoiceCalculations.calculateInvoiceGst(
        items: items,
        discount: 0,
        isInterState: false,
      );

      expect(breakdown.subtotal, 200.0);
      expect(breakdown.taxableValue, 200.0);
      // 18% on 100 = 18, split to 9+9
      // 12% on 100 = 12, split to 6+6
      // Total CGST = 15, SGST = 15
      expect(breakdown.cgst, 15.0);
      expect(breakdown.sgst, 15.0);
      expect(breakdown.total, 230.0);
    });
  });
}
