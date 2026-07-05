import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../data/customer_provider.dart';
import '../../../core/presentation/widgets/searchable_dropdown.dart';
import '../../master_data/domain/master_data_model.dart';
import '../../master_data/data/master_data_repository.dart';
import '../../../core/utils/shared_dialogs.dart';

final localMasterDataProvider = FutureProvider.family<List<MasterDataModel>, String>((ref, type) async {
  return ref.watch(masterDataRepositoryProvider).getMasterData(type);
});

class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? id;
  const CustomerFormScreen({super.key, this.id});

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _address1Ctrl = TextEditingController();
  final _address2Ctrl = TextEditingController();
  final _zipCtrl = TextEditingController();
  final _taxCtrl = TextEditingController();
  final _limitCtrl = TextEditingController(text: '0.0');
  
  String? _selectedType;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedCity;
  bool _isActive = true;
  bool _isLoading = false;
  bool _isCustomCity = false;
  final _customCityCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadCustomer();
    }
  }

  Future<void> _loadCustomer() async {
    setState(() => _isLoading = true);
    try {
      final cust = await ref.read(customerRepositoryProvider).getCustomer(widget.id!);
      _nameCtrl.text = cust.name;
      _emailCtrl.text = cust.email ?? '';
      _phoneCtrl.text = cust.phone ?? '';
      _address1Ctrl.text = cust.addressLine1 ?? '';
      _address2Ctrl.text = cust.addressLine2 ?? '';
      _zipCtrl.text = cust.zipCode ?? '';
      _taxCtrl.text = cust.taxId ?? '';
      _limitCtrl.text = cust.creditLimit.toString();
      _selectedType = cust.customerType?.id;
      _selectedCountry = cust.country?.id;
      _selectedState = cust.state?.id;
      _selectedCity = cust.city?.id;
      _isActive = cust.isActive;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading customer: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final payload = {
      'name': _nameCtrl.text,
      'email': _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
      'phone': _phoneCtrl.text.isEmpty ? null : _phoneCtrl.text,
      'address_line1': _address1Ctrl.text.isEmpty ? null : _address1Ctrl.text,
      'address_line2': _address2Ctrl.text.isEmpty ? null : _address2Ctrl.text,
      'zip_code': _zipCtrl.text.isEmpty ? null : _zipCtrl.text,
      'tax_id': _taxCtrl.text.isEmpty ? null : _taxCtrl.text,
      'credit_limit': double.tryParse(_limitCtrl.text) ?? 0.0,
      'custom_city_name': _isCustomCity && _customCityCtrl.text.isNotEmpty ? _customCityCtrl.text : null,
      'customer_type_id': _selectedType,
      'country_id': _selectedCountry,
      'state_id': _selectedState,
      'city_id': _selectedCity == 'others' ? null : _selectedCity,
      'is_active': _isActive,
    };

    try {
      if (widget.id == null) {
        await ref.read(customerRepositoryProvider).createCustomer(payload);
      } else {
        await ref.read(customerRepositoryProvider).updateCustomer(widget.id!, payload);
      }
      if (mounted) {
        ref.refresh(customersProvider);
        SharedDialogs.showSuccessSnackbar(context, 'Customer saved successfully');
        context.go('/customers');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final typesFuture = ref.watch(localMasterDataProvider('customer_types'));
    final countriesFuture = ref.watch(localMasterDataProvider('countries'));
    final statesFuture = ref.watch(localMasterDataProvider('states'));
    final citiesFuture = ref.watch(localMasterDataProvider('cities'));

    if (_isLoading || typesFuture.isLoading || countriesFuture.isLoading || statesFuture.isLoading || citiesFuture.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final indiaCountry = countriesFuture.value?.where((c) => c.name.toLowerCase() == 'india').firstOrNull;
    if (_selectedCountry == null && indiaCountry != null && widget.id == null) {
      _selectedCountry = indiaCountry.id;
    }

    final filteredStates = statesFuture.value?.where((s) => s.description == _selectedCountry).toList() ?? [];
    print("DEBUG: _selectedCountry='$_selectedCountry', statesTotal=${statesFuture.value?.length}, filteredStates=${filteredStates.length}, indiaCountryId=${indiaCountry?.id}");
    if (statesFuture.value != null && statesFuture.value!.isNotEmpty) {
      print("DEBUG: First state desc='${statesFuture.value!.first.description}' vs _selectedCountry='$_selectedCountry'");
    }

    final filteredCities = citiesFuture.value?.where((c) => c.description == _selectedState).toList() ?? [];
    if (!filteredCities.any((c) => c.id == 'others')) {
      filteredCities.add(MasterDataModel(id: 'others', name: 'Others (Please Specify)', code: '', type: 'cities', description: '', isActive: true, sortOrder: 999));
    }

    return Scaffold(
      appBar: AppBar(title: Text(widget.id == null ? 'Create Customer' : 'Edit Customer')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: _nameCtrl,
                      decoration: const InputDecoration(labelText: 'Company/Individual Name *', border: OutlineInputBorder()),
                      validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _phoneCtrl, decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SearchableDropdown<MasterDataModel>(
                      label: 'Customer Type',
                      items: typesFuture.value ?? [],
                      itemAsString: (e) => e.name,
                      selectedItem: (typesFuture.value ?? []).where((e) => e.id == _selectedType).firstOrNull,
                      onChanged: (val) => setState(() => _selectedType = val?.id),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(controller: _address1Ctrl, decoration: const InputDecoration(labelText: 'Address Line 1', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    TextFormField(controller: _address2Ctrl, decoration: const InputDecoration(labelText: 'Address Line 2', border: OutlineInputBorder())),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SearchableDropdown<MasterDataModel>(
                            label: 'Country',
                            isEnabled: false,
                            items: countriesFuture.value ?? [],
                            itemAsString: (e) => e.name,
                            selectedItem: (countriesFuture.value ?? []).where((e) => e.id == _selectedCountry).firstOrNull,
                            onChanged: (_) {},
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: SearchableDropdown<MasterDataModel>(
                            label: 'State',
                            items: filteredStates,
                            itemAsString: (e) => e.name,
                            selectedItem: filteredStates.where((e) => e.id == _selectedState).firstOrNull,
                            onChanged: (val) => setState(() {
                              _selectedState = val?.id;
                              _selectedCity = null;
                              _isCustomCity = false;
                            }),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: SearchableDropdown<MasterDataModel>(
                            label: 'City',
                            items: filteredCities,
                            itemAsString: (e) => e.name,
                            selectedItem: filteredCities.where((e) => e.id == _selectedCity).firstOrNull,
                            onChanged: (val) => setState(() {
                              _selectedCity = val?.id;
                              _isCustomCity = val?.id == 'others';
                            }),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _zipCtrl, decoration: const InputDecoration(labelText: 'Zip Code', border: OutlineInputBorder()))),
                      ],
                    ),
                    if (_isCustomCity) ...[
                      const SizedBox(height: 16),
                      TextFormField(controller: _customCityCtrl, decoration: const InputDecoration(labelText: 'Specify Custom City', border: OutlineInputBorder())),
                    ],
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: TextFormField(controller: _taxCtrl, decoration: const InputDecoration(labelText: 'Tax ID', border: OutlineInputBorder()))),
                        const SizedBox(width: 16),
                        Expanded(child: TextFormField(controller: _limitCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Credit Limit', border: OutlineInputBorder()))),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('Is Active'),
                      value: _isActive,
                      onChanged: (val) => setState(() => _isActive = val),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(onPressed: () => context.go('/customers'), child: const Text('Cancel')),
                        const SizedBox(width: 16),
                        ElevatedButton(onPressed: _submit, child: const Text('Save')),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
