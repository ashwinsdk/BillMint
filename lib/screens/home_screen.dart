import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('BillMint')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('BillMint', style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 16),
            Text(
              'Invoice & Billing Generator',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 48),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add),
              label: const Text('Create Invoice'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoices',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Customers'),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
