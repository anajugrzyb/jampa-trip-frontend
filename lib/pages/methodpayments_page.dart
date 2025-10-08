import 'package:flutter/material.dart';
import 'pixpayment_page.dart';
import 'cardregister_page.dart'; 

class MetodoPagamentoPage extends StatelessWidget {
  const MetodoPagamentoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Métodos de pagamento",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _metodoItem("Crédito/Débito", "lib/assets/images/cartao.jpg", context),
                _metodoItem("Pix", "lib/assets/images/pix.png", context, highlight: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metodoItem(String nome, String iconPath, BuildContext context, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00008B),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Image.asset(iconPath, width: 40, height: 40),
        title: Text(nome, style: const TextStyle(color: Colors.white, fontSize: 18)),
        trailing: const Icon(Icons.arrow_back, color: Colors.white),
        onTap: () {
          if (nome == "Pix") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const PixPaymentPage()),
            );
          } else if (nome == "Crédito/Débito") {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CardRegisterPage()),
            );
          }
        },
      ),
    );
  }

  Widget _botaoFooter(String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: Colors.white),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF4169E1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
    );
  }
}
