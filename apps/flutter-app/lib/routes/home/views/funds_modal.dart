import 'package:flutter/material.dart';
import 'package:flutter_app/models/fundSubscriptionData.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../bloc/bloc.dart';
import '../../../models/fund.dart';

void showFundDetailsModal(BuildContext context, Fund fund) {
  final currencyFormatter = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
  );
  final percentageFormatter = NumberFormat.decimalPattern('es_CO');
  final formKey = GlobalKey<FormState>();
  final amountController = TextEditingController(
    text: fund.minInvestment.toStringAsFixed(0),
  );

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (modalContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(modalContext).viewInsets.bottom,
          left: 24,
          right: 24,
          top: 24,
        ),
        child: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                fund.name,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              _detailRow(
                'Categoría:',
                categoryValues.reverse[fund.category] ?? 'N/A',
              ),
              _detailRow(
                'Monto Mínimo:',
                currencyFormatter.format(fund.minInvestment),
              ),
              _detailRow(
                'Rendimiento (APY):',
                '${percentageFormatter.format(fund.targetApy)}%',
              ),
              _detailRow('Estado:', statusValues.reverse[fund.status] ?? 'N/A'),
              const SizedBox(height: 16),
              TextFormField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Valor a invertir (\$)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Ingresa un valor';
                  final val = double.tryParse(value);
                  if (val == null) return 'Valor numérico inválido';
                  if (val < fund.minInvestment) {
                    return 'Debe ser mayor o igual al mínimo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  if (formKey.currentState!.validate()) {
                    final amount = double.parse(amountController.text);

                    // Obtenemos el userId desde el LoginBloc en lugar de FirebaseAuth directamente
                    final loginState = context.read<LoginBloc>().state;
                    String userId = '';
                    if (loginState is LoginSuccess) {
                      userId = loginState.user.uid;
                    }

                    // Despacha el evento al Bloc desde el context original
                    context.read<FundsBloc>().add(
                      SubscribeFundRequested(
                        data: FundSubscriptionData(
                          amount: amount,
                          fundId: fund.id,
                          userId: userId,
                        ),
                      ),
                    );
                    Navigator.pop(modalContext);
                  }
                },
                child: const Text('Suscribirse'),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => Navigator.pop(modalContext),
                child: const Text('Cerrar'),
              ),
              const SizedBox(height: 16),
            ],
          ),
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
