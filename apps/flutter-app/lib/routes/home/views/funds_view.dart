import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/bloc.dart';
import '../../../models/fund.dart';

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
    context.read<FundsBloc>().add(LoadFundsRequested());
  }

  void _showFundDetailsModal(BuildContext context, Fund fund) {
    final currencyFormatter = NumberFormat.currency(locale: 'es_CO', symbol: '\$');
    final percentageFormatter = NumberFormat.decimalPattern('es_CO');

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                fund.name,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _detailRow('Categoría:', categoryValues.reverse[fund.category] ?? 'N/A'),
              _detailRow('Monto Mínimo:', currencyFormatter.format(fund.minInvestment)),
              _detailRow('Rendimiento (APY):', '${percentageFormatter.format(fund.targetApy)}%'),
              _detailRow('Estado:', statusValues.reverse[fund.status] ?? 'N/A'),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              )
            ],
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FundsBloc, FundsState>(
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
              context.read<FundsBloc>().add(LoadFundsRequested());
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
                      child: const Icon(Icons.attach_money, color: Colors.white),
                    ),
                    title: Text(
                      fund.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(categoryValues.reverse[fund.category] ?? ''),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => _showFundDetailsModal(context, fund),
                  ),
                );
              },
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
