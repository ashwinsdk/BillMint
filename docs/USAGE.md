# BillMint Usage Guide for Sellers

This guide explains how to use BillMint to create invoices, manage customers and products, and handle your business billing.

## Getting Started

When you first open BillMint, you'll see the home screen with four main sections accessible from the bottom navigation:

1. **Invoices**: View and create invoices
2. **Customers**: Manage customer information
3. **Products**: Manage your product catalog
4. **Settings**: Configure shop details and app settings

## Setting Up Your Shop

Before creating invoices, configure your shop details:

1. Tap **Settings** in the bottom navigation
2. Enter your shop information:
   - Shop Name
   - GSTIN (GST Identification Number)
   - Shop Address
   - Phone Number
   - Email Address
3. Configure invoice settings:
   - Invoice Number Prefix (e.g., "INV")
   - Currency (default: INR)
4. Tap **Save**

## Managing Customers

### Adding a Customer

1. Tap **Customers** in the bottom navigation
2. Tap the **+** button
3. Fill in customer details:
   - Name (required)
   - Phone Number
   - Email
   - Address
   - GSTIN (if customer is GST registered)
4. Tap **Save**

### Editing a Customer

1. Go to **Customers**
2. Tap on the customer you want to edit
3. Modify the details
4. Tap **Save**

### Searching Customers

1. Go to **Customers**
2. Use the search bar at the top
3. Type customer name or phone number
4. Results appear instantly

## Managing Products

### Adding a Product

1. Tap **Products** in the bottom navigation
2. Tap the **+** button
3. Fill in product details:
   - Product Name (required)
   - Description
   - HSN Code (for GST)
   - Unit (pcs, kg, etc.)
   - Price (required)
   - GST Rate (0%, 5%, 12%, 18%, or 28%)
4. Tap **Save**

### Editing a Product

1. Go to **Products**
2. Tap on the product you want to edit
3. Modify the details
4. Tap **Save**

### Searching Products

1. Go to **Products**
2. Use the search bar
3. Type product name
4. Select from results

## Creating an Invoice

### Step 1: Start New Invoice

1. Go to **Invoices**
2. Tap the **+** button
3. Invoice number is auto-generated

### Step 2: Select Customer

1. Tap **Select Customer**
2. Search or select from list
3. Customer details auto-fill
4. Or tap **Quick Add** to create new customer inline

### Step 3: Add Items

1. Tap **Add Item**
2. Search and select product
3. Enter quantity
4. Price auto-fills from product
5. You can modify price if needed
6. GST rate auto-fills
7. Tap **Add**
8. Repeat for more items

### Step 4: Apply Discount (Optional)

1. Tap **Add Discount**
2. Enter discount amount
3. Discount applies to subtotal

### Step 5: Review Calculation

The invoice automatically calculates:
- Subtotal (sum of all items)
- Discount (if any)
- Taxable Value
- CGST and SGST (for intra-state) OR IGST (for inter-state)
- Total Amount

### Step 6: Add Notes (Optional)

1. Scroll to **Notes** section
2. Add payment terms, thank you message, or instructions

### Step 7: Save Invoice

1. Tap **Save Invoice**
2. Invoice is saved to local database

## Viewing and Sharing Invoices

### View Invoice

1. Go to **Invoices**
2. Tap on any invoice to view details
3. See customer info, items, and totals

### Generate PDF

1. Open an invoice
2. Tap **Generate PDF**
3. PDF is created with:
   - Your shop details
   - Customer details
   - Invoice number and date
   - Itemized list with GST breakup
   - UPI QR code for payment
4. PDF generation happens in background

### Share Invoice

1. Generate PDF
2. Tap **Share**
3. Choose app to share (WhatsApp, Email, etc.)
4. Invoice PDF is attached

### Save to Files

1. Generate PDF
2. Tap **Save to Files**
3. Choose location
4. PDF is saved

### Print Invoice

1. Generate PDF
2. Tap **Print**
3. Select printer
4. Print

## Searching Invoices

1. Go to **Invoices**
2. Use search bar
3. Search by:
   - Invoice number
   - Customer name
4. Tap on result to open

## Exporting Data

### Export as CSV

1. Go to **Settings**
2. Tap **Export Data**
3. Choose what to export:
   - All Invoices
   - All Customers
   - All Products
4. CSV file is generated
5. Share or save file

### Backup Data

1. Go to **Settings**
2. Tap **Backup Data**
3. Choose backup location
4. JSON backup file is created
5. Store securely

### Restore Data

1. Go to **Settings**
2. Tap **Restore Data**
3. Select backup file
4. Confirm restoration
5. All data is restored

## Syncing with Backend

If you've set up the backend server:

1. Go to **Settings**
2. Enter **Backend URL**
   - Format: `http://your-server-ip:3000`
   - Or Tailscale IP: `http://100.x.y.z:3000`
3. Tap **Test Connection**
4. If successful, tap **Sync Now**
5. All data syncs to backend

## UPI Payments

Invoices include UPI QR code for easy payment:

1. Generate invoice PDF
2. Share with customer
3. Customer scans QR code with payment app
4. Payment details pre-filled

To configure UPI:

1. Go to **Settings**
2. Enter **UPI ID** (e.g., yourname@paytm)
3. UPI QR code will be included in invoices

## Tips for Efficiency

1. **Add frequently used products** to catalog for quick selection
2. **Use product search** instead of scrolling long lists
3. **Save customer details** to avoid re-entering for repeat customers
4. **Generate PDFs in batch** if sharing multiple invoices
5. **Backup regularly** to protect your data
6. **Use invoice search** to find old invoices quickly

## Troubleshooting

### Invoice not saving
- Check if customer is selected
- Ensure at least one item is added
- Verify all required fields are filled

### PDF not generating
- Wait a few seconds for generation to complete
- Check if device has enough storage
- Try again if it fails

### Sync failing
- Verify backend URL is correct
- Check internet connection
- Ensure backend server is running
- Test connection in Settings

### App running slow
- Close and restart app
- Clear old invoices if database is large
- Export and backup data, then reinstall app

## Support

For issues or questions, contact support or check documentation at [project repository].
