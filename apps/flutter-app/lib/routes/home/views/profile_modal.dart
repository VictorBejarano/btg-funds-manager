import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../models/user.dart';
import '../../../bloc/bloc.dart';

void showEditProfileModal(BuildContext context, User currentUser) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
        ),
        child: _EditProfileForm(user: currentUser),
      );
    },
  );
}

class _EditProfileForm extends StatefulWidget {
  final User user;

  const _EditProfileForm({required this.user});

  @override
  State<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends State<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _lastnameController;
  late TextEditingController _phoneController;
  late TextEditingController _balanceController;
  UserNotificationMethod? _selectedMethod;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _phoneController = TextEditingController(text: widget.user.phone ?? '');
    _balanceController = TextEditingController(text: widget.user.availableBalance.toInt().toString());
    _selectedMethod = widget.user.notificationMethod;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _phoneController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final updatedData = {
        'name': _nameController.text.trim(),
        'lastname': _lastnameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'availableBalance': double.tryParse(_balanceController.text.trim()) ?? widget.user.availableBalance,
        if (_selectedMethod != null)
          'notificationMethod': userNotificationMethodValues.reverse[_selectedMethod],
      };

      context.read<UserBloc>().add(
            UpdateUserDataRequested(
              userId: widget.user.id,
              data: updatedData,
            ),
          );
      
      Navigator.pop(context); // Cierra el modal
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Editar Perfil',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastnameController,
              decoration: const InputDecoration(
                labelText: 'Apellido',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person_outline),
              ),
              validator: (value) =>
                  value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Teléfono',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.phone_outlined),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _balanceController,
              decoration: const InputDecoration(
                labelText: 'Saldo Disponible (Solo Pruebas)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_balance_wallet_outlined),
                prefixText: '\$ ',
              ),
              keyboardType: TextInputType.number,
              validator: (value) =>
                  value == null || value.isEmpty ? 'Requerido' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<UserNotificationMethod>(
              decoration: const InputDecoration(
                labelText: 'Preferencia de Notificación',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.notifications_active_outlined),
              ),
              value: _selectedMethod,
              items: UserNotificationMethod.values.map((method) {
                return DropdownMenuItem(
                  value: method,
                  child: Text(method == UserNotificationMethod.EMAIL ? 'Correo' : 'SMS'),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedMethod = val),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submit,
              child: const Text('Actualizar Datos', style: TextStyle(fontSize: 16)),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
