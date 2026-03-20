import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../models/transaction.dart';

void showTransactionDetailsModal(BuildContext context, Transaction tx) {
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm:ss');

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24.0),
            child: Column(
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
                  'Detalle de Transacción',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // Icono representativo del tipo
                Center(
                  child: CircleAvatar(
                    radius: 30,
                    backgroundColor: tx.type == TransactionType.SUBSCRIBE
                        ? Colors.blue.shade50
                        : Colors.orange.shade50,
                    child: Icon(
                      tx.type == TransactionType.SUBSCRIBE
                          ? Icons.add_circle_outline
                          : Icons.remove_circle_outline,
                      color: tx.type == TransactionType.SUBSCRIBE
                          ? Colors.blue
                          : Colors.orange,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                
                _buildInfoSection('Información General', [
                  _infoRow('Fondo', tx.fundName),
                  _infoRow('Tipo', tx.type == TransactionType.SUBSCRIBE ? 'Suscripción' : 'Cancelación'),
                  _infoRow('Estado', tx.status == TransactionStatus.COMPLETED ? 'Completada' : 'Fallida'),
                  _infoRow('Fecha', dateFormatter.format(tx.createdAt)),
                ]),
                
                const Divider(height: 32),
                
                _buildInfoSection('Detalles Financieros', [
                  _infoRow('Monto Transado', currencyFormatter.format(tx.amount),
                      valueColor: tx.type == TransactionType.SUBSCRIBE ? Colors.red : Colors.green),
                  if (tx.previousBalance != null)
                    _infoRow('Saldo Anterior', currencyFormatter.format(tx.previousBalance)),
                  if (tx.finalBalance != null)
                    _infoRow('Saldo Final', currencyFormatter.format(tx.finalBalance),
                        isBold: true),
                ]),
                
                const Divider(height: 32),
                
                
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.pop(modalContext),
                  child: const Text('Cerrar'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildInfoSection(String title, List<Widget> children) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
          letterSpacing: 1.2,
        ),
      ),
      const SizedBox(height: 12),
      ...children,
    ],
  );
}

Widget _infoRow(String label, String value, {Color? valueColor, bool isBold = false}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(label, style: const TextStyle(color: Colors.blueGrey, fontSize: 14)),
        ),
        Expanded(
          flex: 3,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor,
              fontSize: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
