import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/auth_providers.dart';

class ResetPasswordPage extends ConsumerStatefulWidget {
  const ResetPasswordPage({super.key});

  @override
  ConsumerState<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends ConsumerState<ResetPasswordPage> {
  final passwordController = TextEditingController();

  final confirmPasswordController = TextEditingController();

  bool isLoading = false;
  bool isCancelling = false;

  @override
  void dispose() {
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _updatePassword() async {
    final password = passwordController.text;

    final confirmation = confirmPasswordController.text;

    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password must be at least 6 characters.'),
        ),
      );

      return;
    }

    if (password != confirmation) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match.')));

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await ref
          .read(authRepositoryProvider)
          .updatePassword(newPassword: password);

      await ref.read(authRepositoryProvider).signOut();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password updated successfully. '
            'Sign in with your new password.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to update password: $error')),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> _cancelRecovery() async {
    if (isLoading || isCancelling) return;

    setState(() {
      isCancelling = true;
    });

    try {
      // Password recovery creates a temporary authenticated session. Always
      // sign it out when cancelling before returning to the login screen.
      await ref.read(authRepositoryProvider).signOut();
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to cancel password reset: $error')),
      );

      setState(() {
        isCancelling = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Cancel password reset',
          onPressed: isLoading || isCancelling ? null : _cancelRecovery,
          icon: isCancelling
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.close),
        ),
        title: const Text('Reset password'),
      ),

      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Create a new password',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  const Text('Choose a new password for your account.'),

                  const SizedBox(height: 28),

                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'New Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: confirmPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Confirm Password',
                      prefixIcon: Icon(Icons.lock_outline),
                    ),
                  ),

                  const SizedBox(height: 24),

                  FilledButton(
                    onPressed: isLoading || isCancelling
                        ? null
                        : _updatePassword,
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Update Password'),
                  ),

                  const SizedBox(height: 10),

                  TextButton(
                    onPressed: isLoading || isCancelling
                        ? null
                        : _cancelRecovery,
                    child: const Text('Cancel and return to sign in'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
