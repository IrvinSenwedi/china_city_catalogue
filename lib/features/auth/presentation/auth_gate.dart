import 'package:china_city_catalogue/features/auth/presentation/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../catalogue/presentation/catalogue_page.dart';
import '../providers/auth_providers.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) =>
          Scaffold(body: Center(child: Text('Authentication error: $error'))),
      data: (_) {
        final user = ref.watch(currentUserProvider);

        if (user == null) {
          return const LoginPage();
        }

        return const CataloguePage();
      },
    );
  }
}
