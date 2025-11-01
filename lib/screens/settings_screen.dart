import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/database_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _businessNameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _gstinController;
  late TextEditingController _upiIdController;

  @override
  void initState() {
    super.initState();
    _businessNameController = TextEditingController();
    _addressController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _gstinController = TextEditingController();
    _upiIdController = TextEditingController();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final database = ref.read(databaseProvider);

    if (mounted) {
      final businessName = await database.getSetting('businessName');
      final address = await database.getSetting('businessAddress');
      final phone = await database.getSetting('businessPhone');
      final email = await database.getSetting('businessEmail');
      final gstin = await database.getSetting('gstin');
      final upiId = await database.getSetting('upiId');

      setState(() {
        _businessNameController.text = businessName ?? '';
        _addressController.text = address ?? '';
        _phoneController.text = phone ?? '';
        _emailController.text = email ?? '';
        _gstinController.text = gstin ?? '';
        _upiIdController.text = upiId ?? '';
      });
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _gstinController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        actions: [
          IconButton(icon: const Icon(Icons.save), onPressed: _saveSettings),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text(
              'Business Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Business Address',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _gstinController,
              decoration: const InputDecoration(
                labelText: 'GSTIN',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _upiIdController,
              decoration: const InputDecoration(
                labelText: 'UPI ID',
                border: OutlineInputBorder(),
                helperText: 'For payment QR code in invoices',
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Save Settings'),
              onPressed: _saveSettings,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final database = ref.read(databaseProvider);

      // Save each setting as a key-value pair
      await database.setSetting('businessName', _businessNameController.text);
      await database.setSetting('businessAddress', _addressController.text);
      await database.setSetting('businessPhone', _phoneController.text);
      await database.setSetting('businessEmail', _emailController.text);
      await database.setSetting('gstin', _gstinController.text);
      await database.setSetting('upiId', _upiIdController.text);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    }
  }
}
