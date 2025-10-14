import 'package:flutter/material.dart';
import 'methodpayments_page.dart';  
import 'login_page.dart';
import 'informationuser_page.dart';
import 'feedback_page.dart';

class AccountPage extends StatelessWidget {
  final String userName;
  final String userEmail;
  final double _valorTotal;

  const AccountPage({super.key, required this.userName, required this.userEmail, required double valorTotal}) : _valorTotal = valorTotal;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                ],
              ),
            ),

            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 50,
              backgroundImage: AssetImage("assets/profile.jpg"),
            ),

            const SizedBox(height: 12),

            Text(
              userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Text(
              "Informações",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0018A8), 
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: "Login",
                      subtitle: "Informações de login",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationUserPage(email: userEmail),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.payment,
                      title: "Pagamento",
                      subtitle: "Métodos de pagamento",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MetodoPagamentoPage(valorTotal: _valorTotal),
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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const FeedbackPage(),
                          ),
                        );
                      },
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
                      onPressed: () {

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
        trailing: const Icon(Icons.arrow_back, size: 16, color: Colors.white),
        onTap: onTap,
      ),
    );
  }
}
