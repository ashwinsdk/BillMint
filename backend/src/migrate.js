/**
 * Database initialization and migration script
 * 
 * This script creates the necessary tables for BillMint backend:
 * - customers: Store customer information
 * - products: Store product catalog
 * - invoices: Store invoice records with computed totals and GST breakdowns
 */

const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const fs = require('fs');
require('dotenv').config();

const DB_PATH = process.env.DB_PATH || './data/billmint.sqlite';

// Ensure the directory exists
const dbDir = path.dirname(DB_PATH);
if (!fs.existsSync(dbDir)) {
  fs.mkdirSync(dbDir, { recursive: true });
  console.log(`Created database directory: ${dbDir}`);
}

const db = new sqlite3.Database(DB_PATH, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
    process.exit(1);
  }
  console.log('Connected to SQLite database');
});

// Create tables
db.serialize(() => {
  // Customers table
  db.run(`
    CREATE TABLE IF NOT EXISTS customers (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      address TEXT,
      gstin TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  `, (err) => {
    if (err) {
      console.error('Error creating customers table:', err.message);
    } else {
      console.log('Customers table ready');
    }
  });

  // Products table
  db.run(`
    CREATE TABLE IF NOT EXISTS products (
      id TEXT PRIMARY KEY,
      name TEXT NOT NULL,
      description TEXT,
      hsn_code TEXT,
      unit TEXT DEFAULT 'pcs',
      price REAL NOT NULL,
      gst_rate REAL NOT NULL DEFAULT 0,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
  `, (err) => {
    if (err) {
      console.error('Error creating products table:', err.message);
    } else {
      console.log('Products table ready');
    }
  });

  // Invoices table
  db.run(`
    CREATE TABLE IF NOT EXISTS invoices (
      id TEXT PRIMARY KEY,
      invoice_number TEXT UNIQUE NOT NULL,
      customer_id TEXT NOT NULL,
      customer_name TEXT NOT NULL,
      customer_phone TEXT,
      customer_address TEXT,
      customer_gstin TEXT,
      invoice_date INTEGER NOT NULL,
      due_date INTEGER,
      items TEXT NOT NULL,
      subtotal REAL NOT NULL,
      discount REAL DEFAULT 0,
      taxable_value REAL NOT NULL,
      cgst REAL DEFAULT 0,
      sgst REAL DEFAULT 0,
      igst REAL DEFAULT 0,
      total REAL NOT NULL,
      notes TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL,
      FOREIGN KEY (customer_id) REFERENCES customers(id)
    )
  `, (err) => {
    if (err) {
      console.error('Error creating invoices table:', err.message);
    } else {
      console.log('Invoices table ready');
    }
  });

  // Create indexes for performance
  db.run('CREATE INDEX IF NOT EXISTS idx_customers_name ON customers(name)');
  db.run('CREATE INDEX IF NOT EXISTS idx_products_name ON products(name)');
  db.run('CREATE INDEX IF NOT EXISTS idx_invoices_number ON invoices(invoice_number)');
  db.run('CREATE INDEX IF NOT EXISTS idx_invoices_customer ON invoices(customer_id)');
  db.run('CREATE INDEX IF NOT EXISTS idx_invoices_date ON invoices(invoice_date)');

  console.log('Database migration completed successfully');
});

db.close((err) => {
  if (err) {
    console.error('Error closing database:', err.message);
  }
  console.log('Database connection closed');
});
