import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../data/users_provider.dart';

class UserFormScreen extends ConsumerStatefulWidget {
  final String? id;

  const UserFormScreen({super.key, this.id});

  @override
  ConsumerState<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends ConsumerState<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _departmentController = TextEditingController();
  final _designationController = TextEditingController();

  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final user = await ref.read(userDetailsProvider(widget.id!).future);
      _usernameController.text = user.username;
      _emailController.text = user.email;
      _firstNameController.text = user.firstName;
      _lastNameController.text = user.lastName ?? '';
      _departmentController.text = user.department ?? '';
      _designationController.text = user.designation ?? '';
      _isActive = user.isActive;
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error loading user: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _passwordController.dispose();
    _departmentController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final repo = ref.read(userRepositoryProvider);
      final data = {
        'username': _usernameController.text,
        'email': _emailController.text,
        'first_name': _firstNameController.text,
        'last_name': _lastNameController.text,
        'department': _departmentController.text.isEmpty ? null : _departmentController.text,
        'designation': _designationController.text.isEmpty ? null : _designationController.text,
        'is_active': _isActive,
      };

      if (widget.id == null) {
        data['password'] = _passwordController.text;
        await repo.createUser(data);
      } else {
        if (_passwordController.text.isNotEmpty) {
          data['password'] = _passwordController.text;
        }
        await repo.updateUser(widget.id!, data);
      }

      ref.invalidate(usersProvider);
      if (widget.id != null) ref.invalidate(userDetailsProvider(widget.id!));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User saved successfully')));
        context.go('/users');
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error saving user: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.id == null ? 'Create User' : 'Edit User'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: _isLoading 
                ? const Center(child: CircularProgressIndicator())
                : FilledButton(onPressed: _save, child: const Text('Save')),
          ),
        ],
      ),
      body: _isLoading && widget.id != null
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('User Details', style: Theme.of(context).textTheme.titleLarge),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _firstNameController,
                                decoration: const InputDecoration(labelText: 'First Name *'),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(labelText: 'Last Name'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(labelText: 'Username *'),
                                validator: (val) => val == null || val.isEmpty ? 'Required' : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _emailController,
                                decoration: const InputDecoration(labelText: 'Email *'),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'Required';
                                  if (!val.contains('@')) return 'Invalid email';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _departmentController,
                                decoration: const InputDecoration(labelText: 'Department (e.g. Sales)'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _designationController,
                                decoration: const InputDecoration(labelText: 'Designation (e.g. Sales Person)'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            labelText: widget.id == null ? 'Password *' : 'New Password (leave blank to keep current)',
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (widget.id == null && (val == null || val.isEmpty)) return 'Required';
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        SwitchListTile(
                          title: const Text('Active Status'),
                          subtitle: const Text('If inactive, user cannot log in.'),
                          value: _isActive,
                          onChanged: (val) => setState(() => _isActive = val),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
