import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_bloc.dart';
import 'package:udhaar_app/bloc/customer/customer_event.dart';
import 'package:udhaar_app/bloc/customer/customer_state.dart';
import 'package:udhaar_app/bloc/transaction/transaction_bloc.dart';
import 'package:udhaar_app/core/constants/app_dimensions.dart';
import 'package:udhaar_app/core/extensions/context_extension.dart';
import 'package:udhaar_app/presentations/screens/customer_detail_screen.dart';
import 'package:udhaar_app/presentations/screens/customer_form_screen.dart';
import 'package:udhaar_app/presentations/widgets/balance_chip.dart';
import 'package:udhaar_app/presentations/widgets/customer_tile.dart';
import 'package:udhaar_app/presentations/widgets/empty_view.dart';

class CustomersScreen extends StatelessWidget {
  const CustomersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Customers')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.navigateTo(const CustomerFormScreen()),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('New customer'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints:
          const BoxConstraints(maxWidth: DimensionConstant.maxWideWidth),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    DimensionConstant.padding, 4, DimensionConstant.padding, 12),
                child: TextField(
                  onChanged: (v) => context
                      .read<CustomerBloc>()
                      .add(CustomersSearchChanged(v)),
                  decoration: const InputDecoration(
                    hintText: 'Search by name or phone',
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: BlocBuilder<CustomerBloc, CustomerState>(
                  builder: (context, state) {
                    if (state.status == ListStatus.loading ||
                        state.status == ListStatus.initial) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state.status == ListStatus.failure) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const EmptyView(
                              icon: Icons.error_outline,
                              text: 'Could not load customers.',
                            ),
                            OutlinedButton.icon(
                              onPressed: () => context
                                  .read<CustomerBloc>()
                                  .add(const CustomersStarted()),
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ),
                      );
                    }

                    final list = state.filtered;

                    if (state.customers.isEmpty) {
                      return const EmptyView(
                        icon: Icons.people_outline,
                        text:
                        'No customers yet.\nTap "New customer" to add one.',
                      );
                    }
                    if (list.isEmpty) {
                      return const EmptyView(
                        icon: Icons.search_off,
                        text: 'No customers found.',
                      );
                    }

                    final txState = context.watch<TransactionBloc>().state;
                    final columns = context.isLargeScreen ? 2 : 1;

                    return GridView.builder(
                      padding: const EdgeInsets.fromLTRB(
                          DimensionConstant.padding,
                          0,
                          DimensionConstant.padding,
                          96),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        mainAxisExtent: 76,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: list.length,
                      itemBuilder: (_, i) {
                        final c = list[i];
                        return CustomerTile(
                          customer: c,
                          trailing:
                          BalanceChip(balance: txState.balanceOf(c.id)),
                          onTap: () => context.navigateTo(
                              CustomerDetailScreen(customerId: c.id)),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}