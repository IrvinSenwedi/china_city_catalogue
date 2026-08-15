import 'dart:async';

import 'package:china_city_catalogue/features/auth/presentation/login_page.dart';
import 'package:china_city_catalogue/features/auth/presentation/reset_password_page.dart';
import 'package:china_city_catalogue/features/retailer/presentation/retailer_dashboard_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../catalogue/presentation/catalogue_page.dart';
import '../providers/auth_providers.dart';

class AuthGate extends ConsumerStatefulWidget {
  const AuthGate({super.key});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  StreamSubscription<AuthState>? _authSubscription;

  bool isPasswordRecovery = false;

  @override
  void initState() {
    super.initState();

    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
      (data) {
        if (!mounted) return;

        if (data.event == AuthChangeEvent.passwordRecovery) {
          setState(() {
            isPasswordRecovery = true;
          });

          // A recovery link can reopen the app while ForgotPasswordPage is
          // still above this gate. Remove those pushed auth routes so the
          // reset form becomes visible.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            Navigator.of(context).popUntil((route) => route.isFirst);
          });
        }

        // Updating the password emits userUpdated. Keep recovery mode active
        // until the temporary recovery session has actually signed out.
        if (data.event == AuthChangeEvent.signedOut) {
          if (isPasswordRecovery) {
            setState(() {
              isPasswordRecovery = false;
            });
          }
        }
      },
      onError: (error, stackTrace) {
        debugPrint('Auth state error: $error');
      },
    );
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPasswordRecovery) {
      return const ResetPasswordPage();
    }

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
