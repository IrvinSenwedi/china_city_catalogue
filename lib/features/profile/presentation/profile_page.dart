import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/providers/auth_providers.dart';
import '../providers/profile_providers.dart';
import 'widgets/profile_header.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  final fullNameController = TextEditingController();

  final phoneController = TextEditingController();

  bool initialised = false;
  bool isSaving = false;

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (fullNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter your full name.')));

      return;
    }

    setState(() {
      isSaving = true;
    });

    try {
      await ref
          .read(profileRepositoryProvider)
          .updateProfile(
            fullName: fullNameController.text,
            phoneNumber: phoneController.text,
          );

      ref.invalidate(profileProvider);

      ref.invalidate(currentProfileProvider);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully.')),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to update profile: '
            '$error',
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(profileProvider);

    final repository = ref.watch(profileRepositoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),

      body: profileAsync.when(
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
                  'Unable to load profile',
                  style: Theme.of(context).textTheme.titleMedium,
                ),

                const SizedBox(height: 16),

                FilledButton.icon(
                  onPressed: () {
                    ref.invalidate(profileProvider);
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),

        data: (profile) {
          if (!initialised) {
            fullNameController.text = profile.fullName;

            phoneController.text = profile.phoneNumber ?? '';

            initialised = true;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHeader(name: profile.fullName, role: profile.role),

                const SizedBox(height: 32),

                Text(
                  'Personal Information',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: fullNameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                    text: repository.email ?? '',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email_outlined),
                  ),
                ),

                const SizedBox(height: 16),

                TextField(
                  enabled: false,
                  controller: TextEditingController(
                    text: profile.isRetailer ? 'Retailer' : 'Customer',
                  ),
                  decoration: const InputDecoration(
                    labelText: 'Account Type',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                ),

                const SizedBox(height: 28),

                FilledButton.icon(
                  onPressed: isSaving ? null : _saveProfile,
                  icon: isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: const Text('Save Changes'),
                ),

                const SizedBox(height: 12),

                OutlinedButton.icon(
                  onPressed: () async {
                    await ref.read(authRepositoryProvider).signOut();

                    if (!mounted) {
                      return;
                    }

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sign Out'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
