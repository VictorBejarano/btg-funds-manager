import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/bloc.dart';
import '../../../models/user.dart';
import 'profile_modal.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      context.read<UserBloc>().add(LoadUserDataRequested(loginState.user.uid));
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = 'es_CO';
    final currencyFormatter = NumberFormat.currency(
      locale: locale,
      symbol: '\$',
      decimalDigits: 0,
    );

    return MultiBlocListener(
      listeners: [
        BlocListener<LoginBloc, LoginState>(
          listener: (context, state) {
            if (state is LoginInitial) {
              // Sign out return back to login page logic already handled in AuthWrapper?
            }
          },
        ),
        BlocListener<UserBloc, UserState>(
          listener: (context, state) {
            if (state is UserUpdateSuccess) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message), backgroundColor: Colors.green),
              );
            } else if (state is UserUpdateFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.error), backgroundColor: Colors.red),
              );
            } else if (state is UserUpdateInProgress) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Guardando cambios...')),
              );
            }
          },
        ),
      ],
      child: BlocBuilder<UserBloc, UserState>(
        buildWhen: (previous, current) {
          return current is UserLoadInProgress ||
              current is UserLoadSuccess ||
              current is UserLoadFailure ||
              current is UserInitial;
        },
        builder: (context, state) {
          if (state is UserLoadInProgress || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UserLoadFailure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_off_outlined, color: Colors.orange, size: 60),
                  const SizedBox(height: 16),
                  Text('Error: ${state.error}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadProfile,
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          } else if (state is UserLoadSuccess) {
            final user = state.user;

            return RefreshIndicator(
              onRefresh: () async {
                _loadProfile();
              },
              child: ListView(
                padding: const EdgeInsets.all(24.0),
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                          child: Icon(
                            Icons.person,
                            size: 60,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.secondary,
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              onPressed: () => showEditProfileModal(context, user),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Información Personal
                  const Text('INFORMACIÓN PERSONAL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined, color: Colors.blueGrey),
                          title: const Text('Nombre Completo'),
                          subtitle: Text('${user.name} ${user.lastname}'),
                        ),
                        const Divider(height: 1, indent: 64),
                        ListTile(
                          leading: const Icon(Icons.credit_card_outlined, color: Colors.blueGrey),
                          title: Text('Identificación (${userIdentificationTypeValues.reverse[user.identificationType]})'),
                          subtitle: Text(user.identificationNumber),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  // Contacto
                  const Text('CONTACTO', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.email_outlined, color: Colors.blueGrey),
                          title: const Text('Correo Electrónico'),
                          subtitle: Text(user.email),
                        ),
                        const Divider(height: 1, indent: 64),
                        ListTile(
                          leading: const Icon(Icons.phone_outlined, color: Colors.blueGrey),
                          title: const Text('Teléfono'),
                          subtitle: Text(user.phone ?? 'No especificado'),
                        ),
                        const Divider(height: 1, indent: 64),
                        ListTile(
                          leading: const Icon(Icons.notifications_outlined, color: Colors.blueGrey),
                          title: const Text('Preferencia de Notificación'),
                          subtitle: Text(user.notificationMethod == UserNotificationMethod.EMAIL ? 'Correo Electrónico' : 'Mensaje de Texto (SMS)'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Resumen Financiero
                  const Text('RESUMEN FINANCIERO', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.account_balance_wallet_outlined, color: Colors.green),
                      title: const Text('Saldo Disponible'),
                      trailing: Text(
                        currencyFormatter.format(user.availableBalance),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Botón de Cerrar Sesión
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.logout),
                    label: const Text('Cerrar Sesión'),
                    onPressed: () {
                      context.read<LoginBloc>().add(LogoutRequested());
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

