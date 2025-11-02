# API Documentation

Complete REST API documentation for BillMint backend server.

## Overview

The BillMint backend provides a RESTful API for managing customers, products, invoices, and backups. The API uses JSON for request and response bodies.

**Base URL**: `http://localhost:3000`

**API Version**: 1.0.0

**Authentication**: None (suitable for private networks only)

## Table of Contents

1. [General Information](#general-information)
2. [Health Check](#health-check)
3. [Customers API](#customers-api)
4. [Products API](#products-api)
5. [Invoices API](#invoices-api)
6. [Backup API](#backup-api)
7. [Error Handling](#error-handling)
8. [Examples](#examples)

## General Information

### Request Headers

```
Content-Type: application/json
Accept: application/json
```

### Response Format

All responses follow this structure:

**Success Response:**
```json
{
  "success": true,
  "data": { ... }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Error message"
}
```

### HTTP Status Codes

- `200 OK` - Request successful
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `404 Not Found` - Resource not found
- `500 Internal Server Error` - Server error

## Health Check

### Check Server Status

Check if the API server is running and healthy.

**Endpoint:** `GET /health`

**Response:**
```json
{
  "success": true,
  "message": "BillMint API is running",
  "timestamp": 1762071475057
}
```

**Example:**
```bash
curl http://localhost:3000/health
```

## Customers API

### List All Customers

Retrieve all customers in the database.

**Endpoint:** `GET /api/customers`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "cust_1234567890",
      "name": "John Doe",
      "phone": "9876543210",
      "email": "john@example.com",
      "address": "123 Main St, City, State",
      "gstin": "29ABCDE1234F1Z5",
      "created_at": 1635724800000,
      "updated_at": 1635724800000
    }
  ]
}
```

**Example:**
```bash
curl http://localhost:3000/api/customers
```

### Get Single Customer

Retrieve a specific customer by ID.

**Endpoint:** `GET /api/customers/:id`

**Parameters:**
- `id` (path) - Customer ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "cust_1234567890",
    "name": "John Doe",
    "phone": "9876543210",
    "email": "john@example.com",
    "address": "123 Main St, City, State",
    "gstin": "29ABCDE1234F1Z5",
    "created_at": 1635724800000,
    "updated_at": 1635724800000
  }
}
```

**Example:**
```bash
curl http://localhost:3000/api/customers/cust_1234567890
```

### Create Customer

Create a new customer record.

**Endpoint:** `POST /api/customers`

**Request Body:**
```json
{
  "name": "John Doe",
  "phone": "9876543210",
  "email": "john@example.com",
  "address": "123 Main St, City, State",
  "gstin": "29ABCDE1234F1Z5"
}
```

**Required Fields:**
- `name` (string) - Customer name

**Optional Fields:**
- `phone` (string) - Phone number
- `email` (string) - Email address
- `address` (string) - Physical address
- `gstin` (string) - GST identification number

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "cust_1234567890",
    "name": "John Doe",
    "phone": "9876543210",
    "email": "john@example.com",
    "address": "123 Main St, City, State",
    "gstin": "29ABCDE1234F1Z5",
    "created_at": 1635724800000,
    "updated_at": 1635724800000
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","phone":"9876543210","email":"john@example.com"}'
```

### Update Customer

Update an existing customer record.

**Endpoint:** `PUT /api/customers/:id`

**Parameters:**
- `id` (path) - Customer ID

**Request Body:** (all fields optional)
```json
{
  "name": "John Doe Updated",
  "phone": "9876543211",
  "email": "john.updated@example.com",
  "address": "456 New St, City, State",
  "gstin": "29ABCDE1234F1Z6"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "cust_1234567890",
    "name": "John Doe Updated",
    "phone": "9876543211",
    "email": "john.updated@example.com",
    "address": "456 New St, City, State",
    "gstin": "29ABCDE1234F1Z6",
    "created_at": 1635724800000,
    "updated_at": 1635724900000
  }
}
```

### Delete Customer

Delete a customer record.

**Endpoint:** `DELETE /api/customers/:id`

**Parameters:**
- `id` (path) - Customer ID

**Response:**
```json
{
  "success": true,
  "message": "Customer deleted successfully"
}
```

## Products API

### List All Products

Retrieve all products in the catalog.

**Endpoint:** `GET /api/products`

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "prod_1234567890",
      "name": "Product Name",
      "description": "Product description",
      "hsn_code": "1234",
      "unit": "pcs",
      "price": 100.00,
      "gst_rate": 18.0,
      "created_at": 1635724800000,
      "updated_at": 1635724800000
    }
  ]
}
```

### Get Single Product

Retrieve a specific product by ID.

**Endpoint:** `GET /api/products/:id`

**Parameters:**
- `id` (path) - Product ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "prod_1234567890",
    "name": "Product Name",
    "description": "Product description",
    "hsn_code": "1234",
    "unit": "pcs",
    "price": 100.00,
    "gst_rate": 18.0,
    "created_at": 1635724800000,
    "updated_at": 1635724800000
  }
}
```

### Create Product

Create a new product in the catalog.

**Endpoint:** `POST /api/products`

**Request Body:**
```json
{
  "name": "Product Name",
  "description": "Product description",
  "hsn_code": "1234",
  "unit": "pcs",
  "price": 100.00,
  "gst_rate": 18.0
}
```

**Required Fields:**
- `name` (string) - Product name
- `price` (number) - Product price
- `gst_rate` (number) - GST rate percentage

**Optional Fields:**
- `description` (string) - Product description
- `hsn_code` (string) - HSN code for tax purposes
- `unit` (string) - Unit of measurement (default: "pcs")

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "prod_1234567890",
    "name": "Product Name",
    "description": "Product description",
    "hsn_code": "1234",
    "unit": "pcs",
    "price": 100.00,
    "gst_rate": 18.0,
    "created_at": 1635724800000,
    "updated_at": 1635724800000
  }
}
```

**Example:**
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{"name":"Product Name","price":100,"gst_rate":18,"unit":"pcs"}'
```

### Update Product

Update an existing product.

**Endpoint:** `PUT /api/products/:id`

**Parameters:**
- `id` (path) - Product ID

**Request Body:** (all fields optional)
```json
{
  "name": "Updated Product Name",
  "price": 120.00,
  "gst_rate": 18.0
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "prod_1234567890",
    "name": "Updated Product Name",
    "description": "Product description",
    "hsn_code": "1234",
    "unit": "pcs",
    "price": 120.00,
    "gst_rate": 18.0,
    "created_at": 1635724800000,
    "updated_at": 1635724900000
  }
}
```

### Delete Product

Delete a product from the catalog.

**Endpoint:** `DELETE /api/products/:id`

**Parameters:**
- `id` (path) - Product ID

**Response:**
```json
{
  "success": true,
  "message": "Product deleted successfully"
}
```

## Invoices API

### List All Invoices

Retrieve all invoices.

**Endpoint:** `GET /api/invoices`

**Query Parameters:**
- `customer_id` (optional) - Filter by customer ID
- `limit` (optional) - Limit number of results
- `offset` (optional) - Offset for pagination

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "inv_1234567890",
      "invoice_number": "INV-001",
      "customer_id": "cust_1234567890",
      "customer_name": "John Doe",
      "customer_phone": "9876543210",
      "invoice_date": 1635724800000,
      "due_date": 1636329600000,
      "items": "[...]",
      "subtotal": 1000.00,
      "discount": 50.00,
      "taxable_value": 950.00,
      "cgst": 85.50,
      "sgst": 85.50,
      "igst": 0,
      "total": 1121.00,
      "notes": "Thank you for your business",
      "created_at": 1635724800000,
      "updated_at": 1635724800000
    }
  ]
}
```

### Get Single Invoice

Retrieve a specific invoice by ID.

**Endpoint:** `GET /api/invoices/:id`

**Parameters:**
- `id` (path) - Invoice ID

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "inv_1234567890",
    "invoice_number": "INV-001",
    "customer_id": "cust_1234567890",
    "customer_name": "John Doe",
    "customer_phone": "9876543210",
    "invoice_date": 1635724800000,
    "due_date": 1636329600000,
    "items": "[...]",
    "subtotal": 1000.00,
    "discount": 50.00,
    "taxable_value": 950.00,
    "cgst": 85.50,
    "sgst": 85.50,
    "igst": 0,
    "total": 1121.00,
    "notes": "Thank you for your business",
    "created_at": 1635724800000,
    "updated_at": 1635724800000
  }
}
```

### Create Invoice

Create a new invoice.

**Endpoint:** `POST /api/invoices`

**Request Body:**
```json
{
  "invoice_number": "INV-001",
  "customer_id": "cust_1234567890",
  "customer_name": "John Doe",
  "customer_phone": "9876543210",
  "invoice_date": 1635724800000,
  "due_date": 1636329600000,
  "items": [
    {
      "product_id": "prod_1234567890",
      "name": "Product Name",
      "quantity": 10,
      "unit": "pcs",
      "price": 100.00,
      "gst_rate": 18.0,
      "amount": 1000.00
    }
  ],
  "subtotal": 1000.00,
  "discount": 50.00,
  "taxable_value": 950.00,
  "cgst": 85.50,
  "sgst": 85.50,
  "igst": 0,
  "total": 1121.00,
  "notes": "Thank you for your business"
}
```

**Required Fields:**
- `invoice_number` (string) - Unique invoice number
- `customer_id` (string) - Customer ID
- `customer_name` (string) - Customer name
- `invoice_date` (number) - Invoice date (timestamp)
- `items` (array) - Array of invoice items
- `subtotal` (number) - Subtotal amount
- `total` (number) - Total amount

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "inv_1234567890",
    "invoice_number": "INV-001",
    ...
  }
}
```

### Delete Invoice

Delete an invoice.

**Endpoint:** `DELETE /api/invoices/:id`

**Parameters:**
- `id` (path) - Invoice ID

**Response:**
```json
{
  "success": true,
  "message": "Invoice deleted successfully"
}
```

## Backup API

### Upload Backup

Upload a database backup.

**Endpoint:** `POST /api/backup/upload`

**Request Body:**
```json
{
  "data": {
    "customers": [...],
    "products": [...],
    "invoices": [...]
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Backup uploaded successfully"
}
```

### Download Backup

Download a database backup.

**Endpoint:** `GET /api/backup/download`

**Response:**
```json
{
  "success": true,
  "data": {
    "customers": [...],
    "products": [...],
    "invoices": [...],
    "timestamp": 1635724800000
  }
}
```

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "error": "Detailed error message"
}
```

### Common Errors

**400 Bad Request:**
```json
{
  "success": false,
  "error": "Invalid request data: missing required field 'name'"
}
```

**404 Not Found:**
```json
{
  "success": false,
  "error": "Customer not found"
}
```

**500 Internal Server Error:**
```json
{
  "success": false,
  "error": "Database error: unable to create record"
}
```

## Examples

### Complete Workflow Example

**1. Create a customer:**
```bash
curl -X POST http://localhost:3000/api/customers \
  -H "Content-Type: application/json" \
  -d '{
    "name": "ABC Company",
    "phone": "9876543210",
    "email": "contact@abc.com",
    "gstin": "29ABCDE1234F1Z5"
  }'
```

**2. Create a product:**
```bash
curl -X POST http://localhost:3000/api/products \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Widget",
    "price": 100,
    "gst_rate": 18,
    "unit": "pcs",
    "hsn_code": "1234"
  }'
```

**3. Create an invoice:**
```bash
curl -X POST http://localhost:3000/api/invoices \
  -H "Content-Type: application/json" \
  -d '{
    "invoice_number": "INV-001",
    "customer_id": "cust_1234567890",
    "customer_name": "ABC Company",
    "invoice_date": 1635724800000,
    "items": [{
      "name": "Widget",
      "quantity": 10,
      "price": 100,
      "gst_rate": 18,
      "amount": 1000
    }],
    "subtotal": 1000,
    "discount": 0,
    "total": 1180
  }'
```

### Testing with curl

**Test server health:**
```bash
curl http://localhost:3000/health
```

**List all customers:**
```bash
curl http://localhost:3000/api/customers
```

**Get specific customer:**
```bash
curl http://localhost:3000/api/customers/cust_1234567890
```

**Delete product:**
```bash
curl -X DELETE http://localhost:3000/api/products/prod_1234567890
```

## Rate Limiting

Currently, there is no rate limiting implemented. For production use, consider adding rate limiting middleware.

## CORS Configuration

CORS is enabled for all origins. For production, configure specific allowed origins in `backend/src/index.js`.

## Security Considerations

- No authentication is implemented (suitable for private networks only)
- Use HTTPS in production
- Implement authentication for public deployment
- Configure firewall rules to restrict access
- Use environment variables for sensitive configuration

## Changelog

### Version 1.0.0
- Initial API release
- CRUD operations for customers, products, invoices
- Backup and restore functionality
- Health check endpoint

## Support

For API-related questions or issues:
- GitHub: https://github.com/ashwinsdk/BillMint
- Email: ashwinsdk@github.com
