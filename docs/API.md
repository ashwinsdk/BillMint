# BillMint API Documentation

## Base URL

```
http://localhost:3000/api
```

## Health Check

### GET /health

Check if API is running.

**Response:**
```json
{
  "success": true,
  "message": "BillMint API is running",
  "timestamp": 1699123456789
}
```

## Customers

### GET /api/customers

List all customers.

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Customer Name",
      "phone": "9876543210",
      "email": "customer@example.com",
      "address": "Address",
      "gstin": "GSTIN",
      "created_at": 1699123456789,
      "updated_at": 1699123456789
    }
  ]
}
```

### POST /api/customers

Create new customer.

**Request Body:**
```json
{
  "name": "Customer Name",
  "phone": "9876543210",
  "email": "customer@example.com",
  "address": "Address",
  "gstin": "GSTIN"
}
```

**Response:** Customer object with 201 status

### PUT /api/customers/:id

Update customer.

### DELETE /api/customers/:id

Delete customer.

## Products

### GET /api/products

List all products.

### POST /api/products

Create new product.

**Request Body:**
```json
{
  "name": "Product Name",
  "description": "Description",
  "hsn_code": "1234",
  "unit": "pcs",
  "price": 100.00,
  "gst_rate": 18
}
```

### PUT /api/products/:id

Update product.

### DELETE /api/products/:id

Delete product.

## Invoices

### GET /api/invoices

List invoices with pagination and search.

**Query Parameters:**
- `limit` (default: 100)
- `offset` (default: 0)
- `search`: Search by invoice number or customer name

### POST /api/invoices

Create new invoice.

**Request Body:**
```json
{
  "invoice_number": "INV-2025-001",
  "customer_id": "uuid",
  "customer_name": "Customer Name",
  "invoice_date": 1699123456789,
  "items": [
    {
      "product_id": "uuid",
      "name": "Product",
      "quantity": 2,
      "price": 100,
      "gst_rate": 18,
      "amount": 200
    }
  ],
  "subtotal": 200,
  "discount": 0,
  "taxable_value": 200,
  "cgst": 18,
  "sgst": 18,
  "total": 236
}
```

### PUT /api/invoices/:id

Update invoice.

### DELETE /api/invoices/:id

Delete invoice.

## Backup

### GET /api/backup

Download full database backup as JSON.

**Response:**
```json
{
  "success": true,
  "data": {
    "version": "1.0",
    "timestamp": 1699123456789,
    "data": {
      "customers": [],
      "products": [],
      "invoices": []
    }
  }
}
```

### POST /api/backup

Restore database from JSON backup.

**Request Body:**
```json
{
  "data": {
    "customers": [],
    "products": [],
    "invoices": []
  }
}
```

**Response:**
```json
{
  "success": true,
  "message": "Backup restored successfully",
  "stats": {
    "customers": 10,
    "products": 20,
    "invoices": 50
  }
}
```
