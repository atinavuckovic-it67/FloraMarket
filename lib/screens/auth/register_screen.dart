import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      address: _addressController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registracija uspešna! Dobrodošli, ${_nameController.text.trim()}.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Greška pri registraciji'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kreiranje naloga'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Registrujte se za kupovinu cveća',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'Unesite vaše podatke za lakšu i bržu dostavu',
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                ),
              ),
              const SizedBox(height: 24),

              CustomTextField(
                controller: _nameController,
                label: 'Ime i prezime',
                prefixIcon: Icons.person_outline,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Unesite ime i prezime' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _emailController,
                label: 'Email adresa',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) return 'Unesite email adresu';
                  if (!val.contains('@') || !val.contains('.')) return 'Unesite ispravan email';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _phoneController,
                label: 'Broj telefona',
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (val) => (val == null || val.trim().length < 6) ? 'Unesite broj telefona' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _addressController,
                label: 'Adresa i kućni broj (Novi Sad)',
                prefixIcon: Icons.home_outlined,
                validator: (val) => (val == null || val.trim().isEmpty) ? 'Unesite adresu dostave' : null,
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _passwordController,
                label: 'Lozinka',
                prefixIcon: Icons.lock_outline,
                isPassword: true,
                validator: (val) {
                  if (val == null || val.isEmpty) return 'Unesite lozinku';
                  if (val.length < 6) return 'Lozinka mora imati najmanje 6 karaktera';
                  return null;
                },
              ),
              const SizedBox(height: 14),

              CustomTextField(
                controller: _confirmPasswordController,
                label: 'Potvrdite lozinku',
                prefixIcon: Icons.lock_reset_outlined,
                isPassword: true,
                validator: (val) {
                  if (val != _passwordController.text) return 'Lozinke se ne podudaraju';
                  return null;
                },
              ),

              const SizedBox(height: 28),

              CustomButton(
                text: 'Registruj se (Create Account)',
                isLoading: auth.isLoading,
                icon: Icons.person_add,
                onPressed: auth.isLoading ? null : _handleRegister,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Već imate nalog?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const LoginScreen()),
                      );
                    },
                    child: const Text('Prijavite se', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

