/**
 * Seed script to populate database with sample data for testing
 * 
 * Run with: npm run seed
 */

const { v4: uuidv4 } = require('uuid');
const db = require('./database');

async function seed() {
  console.log('Seeding database with sample data...');

  try {
    // Sample customers
    const customers = [
      {
        id: uuidv4(),
        name: 'Rajesh Kumar',
        phone: '9876543210',
        email: 'rajesh@example.com',
        address: '123 MG Road, Bangalore, Karnataka 560001',
        gstin: '29ABCDE1234F1Z5',
        created_at: Date.now(),
        updated_at: Date.now()
      },
      {
        id: uuidv4(),
        name: 'Priya Sharma',
        phone: '9876543211',
        email: 'priya@example.com',
        address: '456 Park Street, Mumbai, Maharashtra 400001',
        gstin: '27ABCDE5678G1Z5',
        created_at: Date.now(),
        updated_at: Date.now()
      },
      {
        id: uuidv4(),
        name: 'Amit Patel',
        phone: '9876543212',
        email: null,
        address: '789 Station Road, Delhi 110001',
        gstin: null,
        created_at: Date.now(),
        updated_at: Date.now()
      }
    ];

    for (const customer of customers) {
      await db.run(
        `INSERT INTO customers (id, name, phone, email, address, gstin, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?)`,
        [customer.id, customer.name, customer.phone, customer.email, customer.address, customer.gstin, customer.created_at, customer.updated_at]
      );
    }
    console.log(`Created ${customers.length} customers`);

    // Sample products
    const products = [
      {
        id: uuidv4(),
        name: 'Laptop Stand',
        description: 'Adjustable aluminum laptop stand',
        hsn_code: '8473',
        unit: 'pcs',
        price: 1500.00,
        gst_rate: 18,
        created_at: Date.now(),
        updated_at: Date.now()
      },
      {
        id: uuidv4(),
        name: 'Wireless Mouse',
        description: '2.4GHz wireless optical mouse',
        hsn_code: '8471',
        unit: 'pcs',
        price: 450.00,
        gst_rate: 18,
        created_at: Date.now(),
        updated_at: Date.now()
      },
      {
        id: uuidv4(),
        name: 'USB Cable Type-C',
        description: '1 meter Type-C charging cable',
        hsn_code: '8544',
        unit: 'pcs',
        price: 200.00,
        gst_rate: 18,
        created_at: Date.now(),
        updated_at: Date.now()
      },
      {
        id: uuidv4(),
        name: 'Notebook A5',
        description: 'Ruled notebook 100 pages',
        hsn_code: '4820',
        unit: 'pcs',
        price: 80.00,
        gst_rate: 12,
        created_at: Date.now(),
        updated_at: Date.now()
      }
    ];

    for (const product of products) {
      await db.run(
        `INSERT INTO products (id, name, description, hsn_code, unit, price, gst_rate, created_at, updated_at)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [product.id, product.name, product.description, product.hsn_code, product.unit, product.price, product.gst_rate, product.created_at, product.updated_at]
      );
    }
    console.log(`Created ${products.length} products`);

    // Sample invoice
    const invoice = {
      id: uuidv4(),
      invoice_number: 'INV-2025-001',
      customer_id: customers[0].id,
      customer_name: customers[0].name,
      customer_phone: customers[0].phone,
      customer_address: customers[0].address,
      customer_gstin: customers[0].gstin,
      invoice_date: Date.now(),
      due_date: Date.now() + 30 * 24 * 60 * 60 * 1000, // 30 days from now
      items: [
        {
          product_id: products[0].id,
          name: products[0].name,
          hsn_code: products[0].hsn_code,
          quantity: 2,
          unit: products[0].unit,
          price: products[0].price,
          gst_rate: products[0].gst_rate,
          amount: 3000.00
        },
        {
          product_id: products[1].id,
          name: products[1].name,
          hsn_code: products[1].hsn_code,
          quantity: 3,
          unit: products[1].unit,
          price: products[1].price,
          gst_rate: products[1].gst_rate,
          amount: 1350.00
        }
      ],
      subtotal: 4350.00,
      discount: 0,
      taxable_value: 4350.00,
      cgst: 391.50,  // 9% (half of 18%)
      sgst: 391.50,  // 9% (half of 18%)
      igst: 0,
      total: 5133.00,
      notes: 'Thank you for your business!',
      created_at: Date.now(),
      updated_at: Date.now()
    };

    await db.run(
      `INSERT INTO invoices (
        id, invoice_number, customer_id, customer_name, customer_phone, customer_address, customer_gstin,
        invoice_date, due_date, items, subtotal, discount, taxable_value, cgst, sgst, igst, total, notes,
        created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
      [
        invoice.id, invoice.invoice_number, invoice.customer_id, invoice.customer_name,
        invoice.customer_phone, invoice.customer_address, invoice.customer_gstin,
        invoice.invoice_date, invoice.due_date, JSON.stringify(invoice.items),
        invoice.subtotal, invoice.discount, invoice.taxable_value,
        invoice.cgst, invoice.sgst, invoice.igst, invoice.total, invoice.notes,
        invoice.created_at, invoice.updated_at
      ]
    );
    console.log('Created 1 sample invoice');

    console.log('Database seeding completed successfully!');
  } catch (error) {
    console.error('Error seeding database:', error);
    process.exit(1);
  }
}

seed();
