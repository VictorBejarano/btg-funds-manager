import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../bloc/funds/funds_bloc.dart';

class FundsView extends StatelessWidget {
  const FundsView({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<FundsBloc>().add(LoadFundsRequested());
    return const Center(
      child: Text(
        'Pantalla de Fondos',
        style: TextStyle(fontSize: 18),
      ),
    );
  }
}
