import 'package:china_city_catalogue/features/retailer/presentation/widgets/retailer_reservation_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/retailer_providers.dart';
import 'widgets/retailer_reservation_card.dart';

class RetailerReservationsPage extends ConsumerStatefulWidget {
  const RetailerReservationsPage({super.key});

  @override
  ConsumerState<RetailerReservationsPage> createState() =>
      _RetailerReservationsPageState();
}

class _RetailerReservationsPageState
    extends ConsumerState<RetailerReservationsPage> {
  int selectedTab = 0;

  Future<void> _updateStatus({
    required String reservationId,
    required String status,
  }) async {
    try {
      await ref
          .read(retailerRepositoryProvider)
          .updateReservationStatus(
            reservationId: reservationId,
            status: status,
          );

      ref.invalidate(retailerReservationsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reservation ${status.toLowerCase()} successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to update reservation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(retailerReservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Reservations')),

      body: reservationsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),

        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),

                const SizedBox(height: 12),

                Text(
                  'Unable to load reservations',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 6),

                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall,
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(retailerReservationsProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (reservations) {
          if (reservations.isEmpty) {
            return const RetailerReservationsEmptyState();
          }

          final activeReservations = reservations.where((reservation) {
            final status = reservation['status'] ?? 'PENDING';

            return status == 'PENDING' || status == 'CONFIRMED';
          }).toList();

          final historyReservations = reservations.where((reservation) {
            final status = reservation['status'] ?? 'PENDING';

            return status == 'COLLECTED' ||
                status == 'CANCELLED' ||
                status == 'EXPIRED';
          }).toList();

          final visibleReservations = selectedTab == 0
              ? activeReservations
              : historyReservations;

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: SegmentedButton<int>(
                  segments: [
                    ButtonSegment<int>(
                      value: 0,
                      icon: const Icon(Icons.schedule_outlined),
                      label: Text('Active (${activeReservations.length})'),
                    ),
                    ButtonSegment<int>(
                      value: 1,
                      icon: const Icon(Icons.history),
                      label: Text('History (${historyReservations.length})'),
                    ),
                  ],
                  selected: {selectedTab},
                  onSelectionChanged: (selection) {
                    setState(() {
                      selectedTab = selection.first;
                    });
                  },
                ),
              ),

              Expanded(
                child: RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(retailerReservationsProvider);

                    await ref.read(retailerReservationsProvider.future);
                  },

                  child: visibleReservations.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: _RetailerTabEmptyState(
                                isHistory: selectedTab == 1,
                              ),
                            ),
                          ],
                        )
                      : ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
                          itemCount: visibleReservations.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            final reservation = visibleReservations[index];

                            final reservationId = reservation['id'] as String;

                            final quantity = reservation['quantity'] ?? 1;

                            final status = reservation['status'] ?? 'PENDING';

                            final product =
                                reservation['products']
                                    as Map<String, dynamic>?;

                            final customer =
                                reservation['profiles']
                                    as Map<String, dynamic>?;

                            final productName =
                                product?['name'] ?? 'Unknown Product';

                            final customerName =
                                customer?['full_name'] ?? 'Unknown Customer';

                            final collectionAtRaw =
                                reservation['collection_at'];

                            final expiresAtRaw = reservation['expires_at'];

                            final DateTime? collectionAt =
                                collectionAtRaw == null
                                ? null
                                : DateTime.parse(
                                    collectionAtRaw as String,
                                  ).toLocal();

                            final DateTime? expiresAt = expiresAtRaw == null
                                ? null
                                : DateTime.parse(
                                    expiresAtRaw as String,
                                  ).toLocal();

                            return RetailerReservationCard(
                              productName: productName,
                              customerName: customerName,
                              quantity: quantity,
                              status: status,
                              collectionAt: collectionAt,
                              expiresAt: expiresAt,

                              onConfirm: status == 'PENDING'
                                  ? () => _updateStatus(
                                      reservationId: reservationId,
                                      status: 'CONFIRMED',
                                    )
                                  : null,

                              onCollected: status == 'CONFIRMED'
                                  ? () => _updateStatus(
                                      reservationId: reservationId,
                                      status: 'COLLECTED',
                                    )
                                  : null,

                              onCancel:
                                  status == 'PENDING' || status == 'CONFIRMED'
                                  ? () => _updateStatus(
                                      reservationId: reservationId,
                                      status: 'CANCELLED',
                                    )
                                  : null,
                            );
                          },
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RetailerTabEmptyState extends StatelessWidget {
  const _RetailerTabEmptyState({required this.isHistory});

  final bool isHistory;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHistory ? Icons.history : Icons.receipt_long_outlined,
              size: 48,
            ),

            const SizedBox(height: 14),

            Text(
              isHistory ? 'No reservation history' : 'No active reservations',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 6),

            Text(
              isHistory
                  ? 'Collected, cancelled and expired reservations will appear here.'
                  : 'Pending and confirmed customer reservations will appear here.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
