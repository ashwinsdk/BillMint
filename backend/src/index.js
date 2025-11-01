/**
 * BillMint Backend API Server
 * 
 * A simple Express.js REST API for invoice and billing management.
 * Provides endpoints for customers, products, invoices, and backups.
 * Uses SQLite for data storage with no authentication (api/no-auth).
 */

const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');
require('dotenv').config();

const customersRouter = require('./customers');
const productsRouter = require('./products');
const invoicesRouter = require('./invoices');
const backupRouter = require('./backup');

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors()); // Enable CORS for mobile app
app.use(bodyParser.json({ limit: '50mb' })); // Support large backup files
app.use(bodyParser.urlencoded({ extended: true }));

// Request logging
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.path}`);
  next();
});

// Health check
app.get('/health', (req, res) => {
  res.json({ 
    success: true, 
    message: 'BillMint API is running',
    timestamp: Date.now()
  });
});

// API routes
app.use('/api/customers', customersRouter);
app.use('/api/products', productsRouter);
app.use('/api/invoices', invoicesRouter);
app.use('/api/backup', backupRouter);

// 404 handler
app.use((req, res) => {
  res.status(404).json({ 
    success: false, 
    error: 'Endpoint not found' 
  });
});

// Error handler
app.use((err, req, res, next) => {
  console.error('Server error:', err);
  res.status(500).json({ 
    success: false, 
    error: 'Internal server error' 
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`BillMint API server running on port ${PORT}`);
  console.log(`Health check: http://localhost:${PORT}/health`);
  console.log(`API base URL: http://localhost:${PORT}/api`);
});

// Graceful shutdown
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  server.close(() => {
    console.log('HTTP server closed');
  });
});
