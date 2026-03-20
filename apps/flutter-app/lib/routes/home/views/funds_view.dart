import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/bloc.dart';
import '../../../models/fund.dart';
import 'funds_modal.dart';

class FundsView extends StatefulWidget {
  const FundsView({super.key});

  @override
  State<FundsView> createState() => _FundsViewState();
}

class _FundsViewState extends State<FundsView> {
  @override
  void initState() {
    super.initState();
    // Solicita cargar la lista de fondos tan pronto inicia la vista
    _loadFunds();
  }

  void _loadFunds() {
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      context.read<FundsBloc>().add(LoadFundsRequested(userId: loginState.user.uid));
    } else {
      context.read<FundsBloc>().add(const LoadFundsRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<FundsBloc, FundsState>(
      listener: (context, state) {
        if (state is FundSubscriptionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
          // Recarga la lista de fondos después de una suscripción exitosa
          _loadFunds();
        } else if (state is FundSubscriptionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        } else if (state is FundSubscriptionInProgress) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Procesando suscripción...')),
          );
        }
      },
      child: BlocBuilder<FundsBloc, FundsState>(
        buildWhen: (previous, current) {
          // Solo actualiza si cambia el estado de carga del listado general
          return current is FundsLoadInProgress ||
              current is FundsLoadSuccess ||
              current is FundsLoadFailure;
        },
        builder: (context, state) {
          if (state is FundsLoadInProgress || state is FundsInitial) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is FundsLoadFailure) {
            return Center(
              child: Text(
                'Error: ${state.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (state is FundsLoadSuccess) {
            final funds = state.funds;

            if (funds.isEmpty) {
              return const Center(child: Text('No hay fondos disponibles.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                _loadFunds();
              },
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: funds.length,
                itemBuilder: (context, index) {
                  final fund = funds[index];
                  return Card(
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12.0),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      leading: CircleAvatar(
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Icon(
                          Icons.attach_money,
                          color: Colors.white,
                        ),
                      ),
                      title: Text(
                        fund.name,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        categoryValues.reverse[fund.category] ?? '',
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => showFundDetailsModal(context, fund),
                    ),
                  );
                },
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
