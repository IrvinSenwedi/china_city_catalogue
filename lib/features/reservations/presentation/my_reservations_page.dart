import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/reservation_providers.dart';
import 'widgets/reservation_card.dart';
import 'widgets/reservations_empty_state.dart';

class MyReservationsPage extends ConsumerStatefulWidget {
  const MyReservationsPage({super.key});

  @override
  ConsumerState<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends ConsumerState<MyReservationsPage> {
  int selectedTab = 0;

  Future<void> _removeFromHistory(
    String reservationId,
    String productName,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Remove from History?'),
          content: Text(
            '$productName will no longer appear '
            'in your reservation history.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    try {
      await ref
          .read(reservationRepositoryProvider)
          .hideReservation(reservationId: reservationId);

      ref.invalidate(myReservationsProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Removed from history.')));
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to remove reservation: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservationsAsync = ref.watch(myReservationsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('My Reservations')),
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
                    ref.invalidate(myReservationsProvider);
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
            return const ReservationsEmptyState();
          }

          final activeReservations = reservations.where((reservation) {
            return reservation.status == 'PENDING' ||
                reservation.status == 'CONFIRMED';
          }).toList();

          final historyReservations = reservations.where((reservation) {
            return reservation.status == 'COLLECTED' ||
                reservation.status == 'CANCELLED' ||
                reservation.status == 'EXPIRED';
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
                    ref.invalidate(myReservationsProvider);

                    await ref.read(myReservationsProvider.future);
                  },
                  child: visibleReservations.isEmpty
                      ? ListView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * 0.55,
                              child: _TabEmptyState(
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
                            return ReservationCard(
                              reservation: reservation,
                              onRemove: selectedTab == 1
                                  ? () => _removeFromHistory(
                                      reservation.id,
                                      reservation.productName,
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

class _TabEmptyState extends StatelessWidget {
  const _TabEmptyState({required this.isHistory});

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
                  : 'Pending and confirmed reservations will appear here.',
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
