/**
 * Product routes
 * 
 * Endpoints:
 * - GET /api/products - List all products
 * - GET /api/products/:id - Get product by ID
 * - POST /api/products - Create new product
 * - PUT /api/products/:id - Update product
 * - DELETE /api/products/:id - Delete product
 */

const express = require('express');
const { v4: uuidv4 } = require('uuid');
const db = require('./database');

const router = express.Router();

// List all products
router.get('/', async (req, res) => {
  try {
    const products = await db.all('SELECT * FROM products ORDER BY name ASC');
    res.json({ success: true, data: products });
  } catch (error) {
    console.error('Error fetching products:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Get product by ID
router.get('/:id', async (req, res) => {
  try {
    const product = await db.get('SELECT * FROM products WHERE id = ?', [req.params.id]);
    if (product) {
      res.json({ success: true, data: product });
    } else {
      res.status(404).json({ success: false, error: 'Product not found' });
    }
  } catch (error) {
    console.error('Error fetching product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Create new product
router.post('/', async (req, res) => {
  try {
    const { name, description, hsn_code, unit, price, gst_rate } = req.body;
    
    if (!name) {
      return res.status(400).json({ success: false, error: 'Name is required' });
    }
    if (price === undefined || price === null) {
      return res.status(400).json({ success: false, error: 'Price is required' });
    }

    const id = uuidv4();
    const now = Date.now();
    
    await db.run(
      `INSERT INTO products (id, name, description, hsn_code, unit, price, gst_rate, created_at, updated_at)
       VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [id, name, description || null, hsn_code || null, unit || 'pcs', price, gst_rate || 0, now, now]
    );

    const product = await db.get('SELECT * FROM products WHERE id = ?', [id]);
    res.status(201).json({ success: true, data: product });
  } catch (error) {
    console.error('Error creating product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Update product
router.put('/:id', async (req, res) => {
  try {
    const { name, description, hsn_code, unit, price, gst_rate } = req.body;
    const now = Date.now();
    
    const result = await db.run(
      `UPDATE products 
       SET name = ?, description = ?, hsn_code = ?, unit = ?, price = ?, gst_rate = ?, updated_at = ?
       WHERE id = ?`,
      [name, description || null, hsn_code || null, unit || 'pcs', price, gst_rate || 0, now, req.params.id]
    );

    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }

    const product = await db.get('SELECT * FROM products WHERE id = ?', [req.params.id]);
    res.json({ success: true, data: product });
  } catch (error) {
    console.error('Error updating product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

// Delete product
router.delete('/:id', async (req, res) => {
  try {
    const result = await db.run('DELETE FROM products WHERE id = ?', [req.params.id]);
    
    if (result.changes === 0) {
      return res.status(404).json({ success: false, error: 'Product not found' });
    }

    res.json({ success: true, message: 'Product deleted' });
  } catch (error) {
    console.error('Error deleting product:', error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router;
