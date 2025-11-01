import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart' as drift;
import '../data/database.dart';
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
    final settings = await database
        .select(database.appSettings)
        .getSingleOrNull();

    if (settings != null && mounted) {
      setState(() {
        _businessNameController.text = settings.businessName ?? '';
        _addressController.text = settings.businessAddress ?? '';
        _phoneController.text = settings.businessPhone ?? '';
        _emailController.text = settings.businessEmail ?? '';
        _gstinController.text = settings.gstin ?? '';
        _upiIdController.text = settings.upiId ?? '';
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

      await database
          .into(database.appSettings)
          .insertOnConflictUpdate(
            AppSettingsCompanion.insert(
              id: const drift.Value(1),
              businessName: drift.Value(_businessNameController.text),
              businessAddress: drift.Value(_addressController.text),
              businessPhone: drift.Value(_phoneController.text),
              businessEmail: drift.Value(_emailController.text),
              gstin: drift.Value(_gstinController.text),
              upiId: drift.Value(_upiIdController.text),
            ),
          );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Settings saved successfully')),
        );
      }
    }
  }
}
