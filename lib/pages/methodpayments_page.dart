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
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Métodos de pagamento",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Escolha uma forma de pagamento:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            Expanded(
              child: ListView(
                children: [
                  _metodoItem(
                    nome: "Cartão de Crédito/Débito",
                    iconPath: "lib/assets/images/cartao.jpg",
                    context: context,
                  ),
                  _metodoItem(
                    nome: "Pix",
                    iconPath: "lib/assets/images/pix.png",
                    context: context,
                    destaque: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 5,
              ),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              label: const Text(
                "Voltar",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metodoItem({
    required String nome,
    required String iconPath,
    required BuildContext context,
    bool destaque = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (nome.contains("Pix")) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PixPaymentPage()),
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CardRegisterPage()),
          );
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: destaque
              ? Border.all(color: Colors.blue.shade400, width: 1.5)
              : null,
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                iconPath,
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                nome,
                style: TextStyle(
                  color: Colors.blue[900],
                  fontSize: 16,
                  fontWeight: destaque ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Colors.blue[800],
            ),
          ],
        ),
      ),
    );
  }
}
