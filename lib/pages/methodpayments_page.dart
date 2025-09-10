import 'package:flutter/material.dart';

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
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _metodoItem("Visa", "lib/assets/images/visa.png"),
                _metodoItem("MasterCard", "lib/assets/images/mastercard.png"),
                _metodoItem("American Express", "lib/assets/images/americanexpress.png"),
                _metodoItem("Elo", "lib/assets/images/elo.png"),
                _metodoItem("Pix", "lib/assets/images/pix.png", highlight: true),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _botaoFooter("Início", Icons.home, () {
                  Navigator.pop(context);
                }),
                _botaoFooter("Voltar", Icons.arrow_back, () {
                  Navigator.pop(context);
                }),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _metodoItem(String nome, String iconPath, {bool highlight = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF00008B),
        borderRadius: BorderRadius.circular(8),
        border: highlight
            ? Border.all(color: Colors.purpleAccent, width: 2)
            : Border.all(color: Colors.transparent),
      ),
      child: ListTile(
        leading: Image.asset(
          iconPath,
          width: 40,
          height: 40,
        ),
        title: Text(
          nome,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
        onTap: () {
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
