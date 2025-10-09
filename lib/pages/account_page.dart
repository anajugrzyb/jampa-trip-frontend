import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'payment_page.dart';  
import 'login_page.dart';
import '../providers/auth_provider.dart';
import '../middleware/auth_guard.dart';

class AccountPage extends StatelessWidget {
  final String userName;

  const AccountPage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        backgroundColor: const Color(0xFF000080), 
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 8),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    const Text(
                      "Back",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage("lib/assets/images/profile.png"),
              ),
              const SizedBox(height: 12),
              Text(
                userName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Cliente",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 32),
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      _buildMenuItem(
                        icon: Icons.person,
                        title: "Perfil",
                        subtitle: "Editar informações pessoais",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.payment,
                        title: "Pagamentos",
                        subtitle: "Cartões e métodos de pagamento",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const PaymentScreen(),
                            ),
                          );
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.bookmark,
                        title: "Reservas",
                        subtitle: "Minhas reservas, cancelamentos",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.history,
                        title: "Histórico",
                        subtitle: "Meus passeios",
                        onTap: () {},
                      ),
                      _buildMenuItem(
                        icon: Icons.feedback,
                        title: "Feedback",
                        subtitle: "Meus comentários",
                        onTap: () {},
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          final authProvider = Provider.of<AuthProvider>(context, listen: false);
                          await authProvider.logout();
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (context) => const LoginPage()),
                            (Route<dynamic> route) => false,
                          );
                        },
                        icon: const Icon(Icons.logout),
                        label: const Text("Sair"),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade900),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}