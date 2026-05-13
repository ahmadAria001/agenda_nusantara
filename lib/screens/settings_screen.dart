import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/auth_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthController>();
    final success = await auth.updatePassword(
      _currentPasswordController.text,
      _newPasswordController.text,
    );

    if (!mounted) return;

    if (success) {
      _currentPasswordController.clear();
      _newPasswordController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password berhasil diubah'),
          backgroundColor: Theme.of(
            context,
          ).colorScheme.tertiary, // Green success
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Gagal mengubah password'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Pengaturan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Change Password Section ────────────────────────────────
            _sectionTitle('Ubah Password', theme),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      // Current password
                      TextFormField(
                        controller: _currentPasswordController,
                        obscureText: _obscureCurrent,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Password Saat Ini',
                          prefixIcon: const Icon(Icons.lock_outline_rounded),
                          suffixIcon: _visibilityToggle(
                            obscure: _obscureCurrent,
                            onPressed: () => setState(
                              () => _obscureCurrent = !_obscureCurrent,
                            ),
                          ),
                        ),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Masukkan password saat ini'
                            : null,
                      ),
                      const SizedBox(height: 18),

                      // New password
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNew,
                        style: TextStyle(color: theme.colorScheme.onSurface),
                        decoration: InputDecoration(
                          labelText: 'Password Baru',
                          prefixIcon: const Icon(Icons.lock_reset_rounded),
                          suffixIcon: _visibilityToggle(
                            obscure: _obscureNew,
                            onPressed: () =>
                                setState(() => _obscureNew = !_obscureNew),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Masukkan password baru';
                          }
                          if (v.length < 4) {
                            return 'Minimal 4 karakter';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // Submit button
                      Consumer<AuthController>(
                        builder: (context, auth, _) {
                          return SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: auth.isLoading
                                  ? null
                                  : _handleChangePassword,
                              icon: auth.isLoading
                                  ? SizedBox(
                                      width: 18,
                                      height: 18,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    )
                                  : const Icon(Icons.save_rounded, size: 20),
                              label: Text(
                                auth.isLoading ? 'Menyimpan...' : 'Simpan',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: theme.colorScheme.primary,
                                foregroundColor: theme.colorScheme.onPrimary,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 40),

            // ── Developer Identity Section ─────────────────────────────
            _sectionTitle('Identitas Developer', theme),
            const SizedBox(height: 12),
            Card(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Developer photo placeholder
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/dev-img.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Name
                    Text(
                      'Ahmad Aria AS',
                      style: TextStyle(
                        color: theme.colorScheme.onSurface,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // NIM
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'NIM: 2241720247',
                        style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  Widget _sectionTitle(String text, ThemeData theme) {
    return Text(
      text,
      style: TextStyle(
        color: theme.colorScheme.onSurfaceVariant,
        fontSize: 14,
        fontWeight: FontWeight.w600,
        textBaseline: TextBaseline.alphabetic,
      ),
    );
  }

  Widget _visibilityToggle({
    required bool obscure,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_rounded : Icons.visibility_rounded,
      ),
      onPressed: onPressed,
    );
  }
}
