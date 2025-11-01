/**
 * Customer routes
 * 
 * Endpoints:
 * - GET /api/customers - List all customers
 * - GET /api/customers/:id - Get customer by ID
 * - POST /api/customers - Create new customer
 * - PUT /api/customers/:id - Update customer
 * - DELETE /api/customers/:id - Delete customer
 */

const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('./database');

const router = express.Router();

// List all customers
router.get('/', async (req, res) => {
  try {
    const customers = await db.all('SELECT * FROM customers ORDER BY name ASC');
    res.json({ success: true, data: customers });
  } catch (error) {
    console.error('Error fetching customers:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get customer by ID
router.get('/:id', async (req, res) => {
  try {
    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [req.params.id]);
    if (customer) {
      res.json({ success: true, data: customer });
    } else {
      res.status(404).json({ success: false, error: 'Customer not found' });
    }
  } catch (error) {
    console.error('Error fetching customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create new customer
router.post('/', async (req, res) => {
  try {
    const { name, phone, email, address, gstin } = req.body;
    
    if (!name) {
      return res.status(400).json({ success: false, error: 'Name is required' });
    }

    const id = uuidv4();
    const now = Date.now();
    
    await db.run(
      `INSERT INTO customers (id, name, phone, email, address, gstin, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, name, phone || null, email || null, address || null, gstin || null, now, now]
    );

    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [id]);
    res.status(201).json({ success: true, data: customer });
  } catch (error) {
    console.error('Error creating customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update customer
router.put('/:id', async (req, res) => {
  try {
    const { name, phone, email, address, gstin } = req.body;
    const now = Date.now();
    
    const result = await db.run(
      `UPDATE customers 
       SET name = ?, phone = ?, email = ?, address = ?, gstin = ?, updated_at = ?
       WHERE id = ?`,
      [name, phone || null, email || null, address || null, gstin || null, now, req.params.id]
    );

    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Customer not found' });
    }

    const customer = await db.get('SELECT * FROM customers WHERE id = ?', [req.params.id]);
    res.json({ success: true, data: customer });
  } catch (error) {
    console.error('Error updating customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Delete customer
router.delete('/:id', async (req, res) => {
  try {
    const result = await db.run('DELETE FROM customers WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Customer not found' });
    }

    res.json({ success: true, message: 'Customer deleted' });
  } catch (error) {
    console.error('Error deleting customer:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
