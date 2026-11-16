import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final success = await auth.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Uspešna prijava! Dobrodošli, ${auth.currentUser?.fullName}.'),
            backgroundColor: AppColors.primary,
          ),
        );
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Greška pri prijavi'),
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
        title: const Text('Prijava na nalog'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_open_rounded,
                    size: 42,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Center(
                child: Text(
                  'Dobrodošli u FloraMarket',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 6),
              Center(
                child: Text(
                  'Prijavite se da biste koristili korpu i poručivali cveće',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                  ),
                ),
              ),
              const SizedBox(height: 32),

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
              const SizedBox(height: 16),

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

              const SizedBox(height: 24),

              CustomButton(
                text: 'Prijavi se',
                isLoading: auth.isLoading,
                icon: Icons.login,
                onPressed: auth.isLoading ? null : _handleLogin,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Nemate nalog?'),
                  TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (c) => const RegisterScreen()),
                      );
                    },
                    child: const Text('Registrujte se', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),

              const Divider(height: 36),

              // Demo credentials shortcuts
              Text(
                'Brzi demo nalozi za testiranje:',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white60 : Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailController.text = 'kupac@floramarket.rs';
                        _passwordController.text = 'kupac123';
                      },
                      child: const Text('Kupac', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        _emailController.text = 'admin@floramarket.rs';
                        _passwordController.text = 'admin123';
                      },
                      child: const Text('Admin', style: TextStyle(fontSize: 12)),
                    ),
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

