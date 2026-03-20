import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/bloc.dart';
import '../../../models/transaction.dart';
import 'history_modal.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    final loginState = context.read<LoginBloc>().state;
    if (loginState is LoginSuccess) {
      final userId = loginState.user.uid;
      // Despachamos el evento al Bloc obteniendo el ID del usuario del estado de login
      context.read<HistoryBloc>().add(LoadHistoryRequested(userId: userId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      symbol: '\$',
      decimalDigits: 0,
      locale: 'es_CO',
    );
    final dateFormatter = DateFormat('dd/MM HH:mm');

    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoadInProgress || state is HistoryInitial) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HistoryLoadFailure) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.history_toggle_off, color: Colors.orange, size: 64),
                const SizedBox(height: 16),
                Text('Error: ${state.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadHistory,
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        } else if (state is HistoryLoadSuccess) {
          final transactions = state.transactions;

          if (transactions.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.receipt_long_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'Sin transacciones',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('Aquí verás el historial de tus operaciones.',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              _loadHistory();
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                // Definimos el color según el tipo (Subscribe suele ser salida y Unsubscribe suele ser entrada)
                final isSubscribe = tx.type == TransactionType.SUBSCRIBE;
                
                return Card(
                  elevation: 1,
                  margin: const EdgeInsets.only(bottom: 12.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20.0,
                      vertical: 8.0,
                    ),
                    leading: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isSubscribe 
                            ? Colors.red.withOpacity(0.1) 
                            : Colors.green.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSubscribe ? Icons.arrow_outward : Icons.arrow_downward,
                        color: isSubscribe ? Colors.red : Colors.green,
                        size: 20,
                      ),
                    ),
                    title: Text(
                      tx.fundName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Row(
                      children: [
                        Text(
                          isSubscribe ? 'Suscripción' : 'Cancelación',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '• ${dateFormatter.format(tx.createdAt)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade400,
                          ),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${isSubscribe ? "-" : "+"}${currencyFormatter.format(tx.amount)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSubscribe ? Colors.red.shade700 : Colors.green.shade700,
                          ),
                        ),
                        if (tx.status == TransactionStatus.FAILED)
                          const Text(
                            'FALLIDA',
                            style: TextStyle(
                              fontSize: 9,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                      ],
                    ),
                    onTap: () => showTransactionDetailsModal(context, tx),
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
