import 'package:china_city_catalogue/features/reservations/models/reservations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalogue/providers/catalogue_providers.dart';
import '../data/reservation_repository.dart';

final reservationRepositoryProvider = Provider<ReservationRepository>((ref) {
  return ReservationRepository(ref.watch(supabaseProvider));
});

final myReservationsProvider = FutureProvider<List<Reservation>>((ref) async {
  return ref.watch(reservationRepositoryProvider).getMyReservations();
});
