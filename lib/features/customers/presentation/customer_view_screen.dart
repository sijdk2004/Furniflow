import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/customer_provider.dart';

class CustomerViewScreen extends ConsumerStatefulWidget {
  final String id;
  const CustomerViewScreen({super.key, required this.id});

  @override
  ConsumerState<CustomerViewScreen> createState() => _CustomerViewScreenState();
}

class _CustomerViewScreenState extends ConsumerState<CustomerViewScreen> {
  bool _isLoading = true;
  dynamic _customer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      _customer = await ref.read(customerRepositoryProvider).getCustomer(widget.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    if (_customer == null) return const Scaffold(body: Center(child: Text('Customer not found')));

    return Scaffold(
      appBar: AppBar(title: const Text('Customer Details')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                _buildRow('Name:', _customer.name),
                _buildRow('Email:', _customer.email ?? '-'),
                _buildRow('Phone:', _customer.phone ?? '-'),
                _buildRow('Customer Type:', _customer.customerType?.name ?? '-'),
                const Divider(),
                _buildRow('Address 1:', _customer.addressLine1 ?? '-'),
                _buildRow('Address 2:', _customer.addressLine2 ?? '-'),
                _buildRow('City:', _customer.city?.name ?? '-'),
                _buildRow('State:', _customer.state?.name ?? '-'),
                _buildRow('Country:', _customer.country?.name ?? '-'),
                _buildRow('Zip Code:', _customer.zipCode ?? '-'),
                const Divider(),
                _buildRow('Tax ID:', _customer.taxId ?? '-'),
                _buildRow('Credit Limit:', _customer.creditLimit.toString()),
                _buildRow('Status:', _customer.isActive ? 'Active' : 'Inactive'),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/customers');
                    }
                  }, 
                  child: const Text('Back to List')
                ),
              ],
            ),
          ),
        ),
      ),
    ),
    );
  }

  Widget _buildRow(String label, String val) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 150, child: Text(label, style: const TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text(val)),
        ],
      ),
    );
  }
}
