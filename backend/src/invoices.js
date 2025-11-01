/**
 * Invoice routes
 * 
 * Endpoints:
 * - GET /api/invoices - List all invoices
 * - GET /api/invoices/:id - Get invoice by ID
 * - POST /api/invoices - Create new invoice
 * - PUT /api/invoices/:id - Update invoice
 * - DELETE /api/invoices/:id - Delete invoice
 */

const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('./database');

const router = express.Router();

// List all invoices with pagination and search
router.get('/', async (req, res) => {
  try {
    const limit = parseInt(req.query.limit) || 100;
    const offset = parseInt(req.query.offset) || 0;
    const search = req.query.search || '';

    let query = 'SELECT * FROM invoices';
    let params = [];

    if (search) {
      query += ' WHERE invoice_number LIKE ? OR customer_name LIKE ?';
      params = [`%${search}%`, `%${search}%`];
    }

    query += ' ORDER BY invoice_date DESC LIMIT ? OFFSET ?';
    params.push(limit, offset);

    const invoices = await db.all(query, params);
    
    // Parse items JSON for each invoice
    const parsedInvoices = invoices.map(inv => ({
      ...inv,
      items: JSON.parse(inv.items)
    }));

    res.json({ success: true, data: parsedInvoices });
  } catch (error) {
    console.error('Error fetching invoices:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get invoice by ID
router.get('/:id', async (req, res) => {
  try {
    const invoice = await db.get('SELECT * FROM invoices WHERE id = ?', [req.params.id]);
    if (invoice) {
      invoice.items = JSON.parse(invoice.items);
      res.json({ success: true, data: invoice });
    } else {
      res.status(404).json({ success: false, error: 'Invoice not found' });
    }
  } catch (error) {
    console.error('Error fetching invoice:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create new invoice
router.post('/', async (req, res) => {
  try {
    const {
      invoice_number,
      customer_id,
      customer_name,
      customer_phone,
      customer_address,
      customer_gstin,
      invoice_date,
      due_date,
      items,
      subtotal,
      discount,
      taxable_value,
      cgst,
      sgst,
      igst,
      total,
      notes
    } = req.body;
    
    if (!invoice_number || !customer_id || !customer_name || !items || !Array.isArray(items)) {
      return res.status(400).json({ 
        success: false, 
        error: 'Missing required fields: invoice_number, customer_id, customer_name, items' 
      });
    }

    const id = uuidv4();
    const now = Date.now();
    
    await db.run(
      `INSERT INTO invoices (
        id, invoice_number, customer_id, customer_name, customer_phone, customer_address, customer_gstin,
        invoice_date, due_date, items, subtotal, discount, taxable_value, cgst, sgst, igst, total, notes,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        id, invoice_number, customer_id, customer_name, 
        customer_phone || null, customer_address || null, customer_gstin || null,
        invoice_date || now, due_date || null, JSON.stringify(items),
        subtotal || 0, discount || 0, taxable_value || 0,
        cgst || 0, sgst || 0, igst || 0, total || 0, notes || null,
        now, now
      ]
    );

    const invoice = await db.get('SELECT * FROM invoices WHERE id = ?', [id]);
    invoice.items = JSON.parse(invoice.items);
    res.status(201).json({ success: true, data: invoice });
  } catch (error) {
    console.error('Error creating invoice:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update invoice
router.put('/:id', async (req, res) => {
  try {
    const {
      invoice_number,
      customer_id,
      customer_name,
      customer_phone,
      customer_address,
      customer_gstin,
      invoice_date,
      due_date,
      items,
      subtotal,
      discount,
      taxable_value,
      cgst,
      sgst,
      igst,
      total,
      notes
    } = req.body;
    
    const now = Date.now();
    
    const result = await db.run(
      `UPDATE invoices 
       SET invoice_number = ?, customer_id = ?, customer_name = ?, customer_phone = ?, 
           customer_address = ?, customer_gstin = ?, invoice_date = ?, due_date = ?,
           items = ?, subtotal = ?, discount = ?, taxable_value = ?, cgst = ?, sgst = ?, igst = ?,
           total = ?, notes = ?, updated_at = ?
       WHERE id = ?`,
      [
        invoice_number, customer_id, customer_name, customer_phone || null,
        customer_address || null, customer_gstin || null, invoice_date, due_date || null,
        JSON.stringify(items), subtotal || 0, discount || 0, taxable_value || 0,
        cgst || 0, sgst || 0, igst || 0, total || 0, notes || null, now,
        req.params.id
      ]
    );

    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Invoice not found' });
    }

    const invoice = await db.get('SELECT * FROM invoices WHERE id = ?', [req.params.id]);
    invoice.items = JSON.parse(invoice.items);
    res.json({ success: true, data: invoice });
  } catch (error) {
    console.error('Error updating invoice:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Delete invoice
router.delete('/:id', async (req, res) => {
  try {
    const result = await db.run('DELETE FROM invoices WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Invoice not found' });
    }

    res.json({ success: true, message: 'Invoice deleted' });
  } catch (error) {
    console.error('Error deleting invoice:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
