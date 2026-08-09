import 'package:china_city_catalogue/features/auth/presentation/login_page.dart';
import 'package:china_city_catalogue/features/retailer/presentation/retailer_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalogue/presentation/catalogue_page.dart';
import '../providers/auth_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(currentProfileProvider);

    return profileAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        body: Center(child: Text('Failed to load profile.\n$error')),
      ),
      data: (profile) {
        if (profile == null) {
          return const LoginPage();
        }

        if (profile.isRetailer) {
          return const RetailerDashboardPage();
        }

        return const CataloguePage();
      },
    );
  }
}
