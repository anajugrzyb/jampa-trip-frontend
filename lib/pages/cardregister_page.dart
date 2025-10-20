import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'reservationconfirmed_page.dart';

class CardRegisterPage extends StatefulWidget {
  final double valorTotal;

  const CardRegisterPage({super.key, required this.valorTotal});

  @override
  State<CardRegisterPage> createState() => _CardRegisterPageState();
}

class _CardRegisterPageState extends State<CardRegisterPage> {
  final _holderController = TextEditingController();
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();

  String? _selectedMonth;
  String? _selectedYear;
  bool _saveCard = false; 

  bool _isValidCardNumber(String number) {
    if (!RegExp(r'^[0-9]{13,19}$').hasMatch(number)) return false;

    int sum = 0;
    bool alternate = false;
    for (int i = number.length - 1; i >= 0; i--) {
      int digit = int.parse(number[i]);
      if (alternate) {
        digit *= 2;
        if (digit > 9) digit -= 9;
      }
      sum += digit;
      alternate = !alternate;
    }
    return sum % 10 == 0;
  }

  Future<void> _processPayment() async {
    final holder = _holderController.text.trim();
    final number = _numberController.text.trim().replaceAll(' ', '');
    final cvv = _cvvController.text.trim();

    if (holder.isEmpty ||
        number.isEmpty ||
        _selectedMonth == null ||
        _selectedYear == null ||
        cvv.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preencha todos os campos!")),
      );
      return;
    }

    if (!_isValidCardNumber(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Número do cartão inválido.")),
      );
      return;
    }

    if (!RegExp(r'^[0-9]{3,4}$').hasMatch(cvv)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("CVV inválido. Deve conter 3 ou 4 dígitos.")),
      );
      return;
    }

    if (_saveCard) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xFF001E6C),
          title: const Text(
            "Salvar cartão?",
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            "Deseja realmente salvar este cartão para futuras compras?",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Não", style: TextStyle(color: Colors.white)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Sim", style: TextStyle(color: Colors.lightBlueAccent)),
            ),
          ],
        ),
      );

      if (confirm == true) {
        final db = DBHelper();
        await db.insertCard({
          'nome_titular': holder,
          'numero_cartao': number,
          'mes': _selectedMonth,
          'ano': _selectedYear,
          'cvv': cvv,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Cartão salvo com sucesso!")),
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          "Pagamento de R\$ ${widget.valorTotal.toStringAsFixed(2)} aprovado!",
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 1), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ReservationConfirmedPage()),
      );
    });
  }

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
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Insira as informações do cartão',
              style: TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            TextField(
              controller: _holderController,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Nome do titular'),
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _numberController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              maxLength: 19,
              decoration:
                  _inputDecoration('Número do cartão').copyWith(counterText: ""),
            ),
            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedMonth,
                    dropdownColor: const Color(0xFF001C92),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Mês'),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: (i + 1).toString().padLeft(2, '0'),
                        child: Text(
                          (i + 1).toString().padLeft(2, '0'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onChanged: (val) => setState(() => _selectedMonth = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: _selectedYear,
                    dropdownColor: const Color(0xFF001C92),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Ano'),
                    items: List.generate(
                      20,
                      (i) => DropdownMenuItem(
                        value: (2025 + i).toString(),
                        child: Text(
                          (2025 + i).toString(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    onChanged: (val) => setState(() => _selectedYear = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),

            TextField(
              controller: _cvvController,
              style: const TextStyle(color: Colors.white),
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: _inputDecoration('CVV', helper: '3 ou 4 dígitos')
                  .copyWith(counterText: ""),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Salvar cartão para futuras compras",
                  style: TextStyle(color: Colors.white, fontSize: 15),
                ),
                Switch(
                  value: _saveCard,
                  activeColor: Colors.lightBlueAccent,
                  onChanged: (val) => setState(() => _saveCard = val),
                ),
              ],
            ),
            const SizedBox(height: 25),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _processPayment,
              child: const Text(
                'Pagar',
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
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
      helperStyle: const TextStyle(color: Colors.white, fontSize: 11),
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
}
