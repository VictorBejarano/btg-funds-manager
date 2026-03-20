import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../bloc/bloc.dart';
import '../../../models/subscription.dart';

void showSubscriptionDetailsModal(BuildContext context, Subscription sub) {
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );
  final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (modalContext) {
      return Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 48, color: Colors.blueGrey),
            const SizedBox(height: 16),
            Text(
              sub.fundName,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            _infoRow('ID Suscripción', sub.id),
            _infoRow('Monto Invertido', currencyFormatter.format(sub.amount)),
            _infoRow('Fecha de Inicio', dateFormatter.format(sub.createdAt)),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => _confirmUnsubscribe(context, modalContext, sub),
              child: const Text(
                'Desuscribirse',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(modalContext),
              child: const Text('Cerrar'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    },
  );
}

void _confirmUnsubscribe(BuildContext context, BuildContext modalContext, Subscription sub) {
  showDialog(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: const Text('¿Estás seguro?'),
      content: const Text(
          'Esta acción cancelará tu suscripción al fondo y devolverá el monto invertido a tu saldo disponible.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: const Text('NO', style: TextStyle(color: Colors.grey)),
        ),
        TextButton(
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          onPressed: () {
            context.read<SubscriptionsBloc>().add(
                  UnsubscribeRequested(
                    userId: sub.userId,
                    subscriptionId: sub.id,
                  ),
                );
            Navigator.pop(dialogContext); // Cierra el diálogo
            Navigator.pop(modalContext); // Cierra el bottom sheet
          },
          child: const Text('SÍ, DESUSCRIBIR', style: TextStyle(fontWeight: FontWeight.bold)),
        ),
      ],
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 8.0),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
      ],
    ),
  );
}
