import 'package:flutter/material.dart';

class CardRegisterPage extends StatelessWidget {
  const CardRegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001C92), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF001C92),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Adicionar Cartão',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10),
            const Text(
              'Insira as informações do cartão',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
      
            const SizedBox(height: 25),

            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Nome do titular'),
            ),
            const SizedBox(height: 15),

            TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('Número do cartão'),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF001C92),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Mês'),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: (i + 1).toString().padLeft(2, '0'),
                        child: Text((i + 1).toString().padLeft(2, '0')),
                      ),
                    ),
                    onChanged: (_) {},
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    dropdownColor: const Color(0xFF001C92),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Ano'),
                    items: List.generate(
                      20,
                      (i) => DropdownMenuItem(
                        value: (2025 + i).toString(),
                        child: Text((2025 + i).toString()),
                      ),
                    ),
                    onChanged: (_) {},
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            TextField(
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              decoration: _inputDecoration('CVV', helper: '3 ou 4 dígitos'),
            ),
            const SizedBox(height: 25),

            Row(
              children: [
                Switch(
                  value: true,
                  onChanged: (_) {},
                  activeColor: Colors.white,
                ),
                const Text(
                  "Salvar este cartão",
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 25),

            // Botão adicionar
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
              child: const Text(
                'Adicionar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _bottomButton(Icons.home, 'Início', () {}),
                _bottomButton(Icons.arrow_back, 'Voltar', () {
                  Navigator.pop(context);
                }),
              ],
            )
          ],
        ),
      ),
    );
  }

  static InputDecoration _inputDecoration(String hint, {String? helper}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white70),
      helperText: helper,
      helperStyle: const TextStyle(color: Colors.white54, fontSize: 11),
      filled: true,
      fillColor: const Color(0xFF001070),
      contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _bottomButton(IconData icon, String label, VoidCallback onTap) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF3355FF),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onPressed: onTap,
      icon: Icon(icon, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }
}

