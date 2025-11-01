/**
 * Backup routes
 * 
 * Endpoints:
 * - GET /api/backup - Download full database backup as JSON
 * - POST /api/backup - Upload and restore database from JSON backup
 */

const express = require('express');
const db = require('./database');

const router = express.Router();

// Download backup
router.get('/', async (req, res) => {
  try {
    const customers = await db.all('SELECT * FROM customers');
    const products = await db.all('SELECT * FROM products');
    const invoices = await db.all('SELECT * FROM invoices');
    
    // Parse invoice items
    const parsedInvoices = invoices.map(inv => ({
      ...inv,
      items: JSON.parse(inv.items)
    }));

    const backup = {
      version: '1.0',
      timestamp: Date.now(),
      data: {
        customers,
        products,
        invoices: parsedInvoices
      }
    };

    res.json({ success: true, data: backup });
  } catch (error) {
    console.error('Error creating backup:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Upload and restore backup
router.post('/', async (req, res) => {
  try {
    const { data } = req.body;
    
    if (!data || !data.customers || !data.products || !data.invoices) {
      return res.status(400).json({ 
        success: false, 
        error: 'Invalid backup format. Expected data.customers, data.products, data.invoices' 
      });
    }

    // Clear existing data
    await db.run('DELETE FROM invoices');
    await db.run('DELETE FROM products');
    await db.run('DELETE FROM customers');

    // Restore customers
    for (const customer of data.customers) {
      await db.run(
        `INSERT INTO customers (id, name, phone, email, address, gstin, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          customer.id,
          customer.name,
          customer.phone,
          customer.email,
          customer.address,
          customer.gstin,
          customer.created_at,
          customer.updated_at
        ]
      );
    }

    // Restore products
    for (const product of data.products) {
      await db.run(
        `INSERT INTO products (id, name, description, hsn_code, unit, price, gst_rate, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          product.id,
          product.name,
          product.description,
          product.hsn_code,
          product.unit,
          product.price,
          product.gst_rate,
          product.created_at,
          product.updated_at
        ]
      );
    }

    // Restore invoices
    for (const invoice of data.invoices) {
      await db.run(
        `INSERT INTO invoices (
          id, invoice_number, customer_id, customer_name, customer_phone, customer_address, customer_gstin,
          invoice_date, due_date, items, subtotal, discount, taxable_value, cgst, sgst, igst, total, notes,
          created_at, updated_at
        ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          invoice.id,
          invoice.invoice_number,
          invoice.customer_id,
          invoice.customer_name,
          invoice.customer_phone,
          invoice.customer_address,
          invoice.customer_gstin,
          invoice.invoice_date,
          invoice.due_date,
          JSON.stringify(invoice.items),
          invoice.subtotal,
          invoice.discount,
          invoice.taxable_value,
          invoice.cgst,
          invoice.sgst,
          invoice.igst,
          invoice.total,
          invoice.notes,
          invoice.created_at,
          invoice.updated_at
        ]
      );
    }

    res.json({ 
      success: true, 
      message: 'Backup restored successfully',
      stats: {
        customers: data.customers.length,
        products: data.products.length,
        invoices: data.invoices.length
      }
    });
  } catch (error) {
    console.error('Error restoring backup:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
