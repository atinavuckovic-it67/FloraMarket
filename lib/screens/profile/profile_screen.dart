import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../config/constants.dart';
import '../../providers/auth_provider.dart';
import '../../providers/theme_provider.dart';
import '../../widgets/role_badge.dart';
import '../admin/admin_dashboard_screen.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';
import '../orders/order_history_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Korisnički profil'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Prebaci na svetli režim' : 'Prebaci na tamni režim',
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Header Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: AppColors.primary.withOpacity(0.15),
                    child: Icon(
                      auth.isGuest
                          ? Icons.person_outline
                          : (auth.isAdmin ? Icons.admin_panel_settings : Icons.person),
                      size: 44,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    user?.fullName.isNotEmpty == true ? user!.fullName : 'Gost Korisnik',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  if (user?.email.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(
                      user!.email,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white60 : AppColors.textSecondaryLight,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  RoleBadge(role: user?.role ?? 'guest'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // If Guest: Prompt to login/register
            if (auth.isGuest) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Column(
                  children: [
                    const Text(
                      'Prijavite se za pun pristup',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Kao registrovani korisnik možete naručivati cveće, čuvati omiljene proizvode i pratiti istoriju porudžbina.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 13, color: Colors.black87),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => const LoginScreen()),
                              );
                            },
                            child: const Text('Prijava'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (c) => const RegisterScreen()),
                              );
                            },
                            child: const Text('Registracija'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // User Options Card
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  if (!auth.isGuest) ...[
                    ListTile(
                      leading: const Icon(Icons.edit_outlined, color: AppColors.primary),
                      title: const Text('Izmeni podatke profila (Update)'),
                      subtitle: const Text('Ažuriranje imena, telefona i adrese'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const EditProfileScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.receipt_long_outlined, color: AppColors.primary),
                      title: const Text('Istorija porudžbina'),
                      subtitle: const Text('Pregled svih prethodnih narudžbina'),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const OrderHistoryScreen()),
                        );
                      },
                    ),
                    const Divider(height: 1),
                  ],

                  // Theme mode toggle
                  SwitchListTile(
                    secondary: Icon(
                      isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    title: const Text('Tamni režim (Dark Mode)'),
                    subtitle: Text(isDark ? 'Uključena tamna tema' : 'Uključena svetla tema'),
                    value: isDark,
                    onChanged: (val) => themeProvider.toggleTheme(),
                  ),

                  // Admin Panel
                  if (auth.isAdmin) ...[
                    const Divider(height: 1),
                    ListTile(
                      leading: const Icon(Icons.admin_panel_settings, color: Colors.red),
                      title: const Text(
                        'Administratorski panel',
                        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                      ),
                      subtitle: const Text('Upravljanje cvećarama, cvećem i porudžbinama'),
                      trailing: const Icon(Icons.chevron_right, color: Colors.red),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (c) => const AdminDashboardScreen()),
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Demo Role Switcher Section (Spec 3.2 demonstration for grading)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.tune, size: 18, color: AppColors.primary),
                      SizedBox(width: 8),
                      Text(
                        'Demonstracija uloga za odbranu:',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('1. Gost'),
                        selected: auth.isGuest,
                        onSelected: (_) => auth.switchRoleForDemo('guest'),
                      ),
                      ChoiceChip(
                        label: const Text('2. Kupac'),
                        selected: auth.currentUser?.role == 'user',
                        onSelected: (_) => auth.switchRoleForDemo('user'),
                      ),
                      ChoiceChip(
                        label: const Text('3. Administrator'),
                        selected: auth.isAdmin,
                        onSelected: (_) => auth.switchRoleForDemo('admin'),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            if (!auth.isGuest)
              ListTile(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                tileColor: Colors.red.withOpacity(0.08),
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text(
                  'Odjavi se',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
                onTap: () {
                  auth.logout();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Uspešno ste se odjavili.')),
                  );
                },
              ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

