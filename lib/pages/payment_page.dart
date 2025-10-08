import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'methodpayments_page.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  List<Map<String, dynamic>> _cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final db = DBHelper();
    final cards = await db.getCards();
    setState(() => _cards = cards);
  }

  Future<void> _deleteCard(int id) async {
    final db = DBHelper();
    await db.deleteCard(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Cartão excluído com sucesso!")),
    );
    _loadCards();
  }

  Future<void> _editCard(Map<String, dynamic> card) async {
    final holderController = TextEditingController(text: card['nome_titular']);
    final numberController = TextEditingController(text: card['numero_cartao']);
    final cvvController = TextEditingController(text: card['cvv']);
    String? selectedMonth = card['mes'];
    String? selectedYear = card['ano'];

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF001C92),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: const Text(
            "Editar Cartão",
            style: TextStyle(color: Colors.white),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: holderController,
                  style: const TextStyle(color: Colors.white),
                  decoration: _inputDecoration("Nome do titular"),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: numberController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  maxLength: 16,
                  decoration: _inputDecoration("Número do cartão").copyWith(counterText: ""),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedMonth,
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
                        onChanged: (val) => selectedMonth = val,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        value: selectedYear,
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
                        onChanged: (val) => selectedYear = val,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: cvvController,
                  style: const TextStyle(color: Colors.white),
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  decoration: _inputDecoration("CVV").copyWith(counterText: ""),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(
              child: const Text("Salvar", style: TextStyle(color: Colors.lightBlueAccent)),
              onPressed: () async {
                final holder = holderController.text.trim();
                final number = numberController.text.trim().replaceAll(' ', '');
                final cvv = cvvController.text.trim();

                if (holder.isEmpty ||
                    number.isEmpty ||
                    selectedMonth == null ||
                    selectedYear == null ||
                    cvv.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Preencha todos os campos!")),
                  );
                  return;
                }

                final isValidNumber = RegExp(r'^[0-9]{16}$').hasMatch(number);
                if (!isValidNumber) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("O número deve ter 16 dígitos numéricos.")),
                  );
                  return;
                }

                final db = DBHelper();
                await db.db.then((database) async {
                  await database.update(
                    'cards',
                    {
                      'nome_titular': holder,
                      'numero_cartao': number,
                      'mes': selectedMonth,
                      'ano': selectedYear,
                      'cvv': cvv,
                    },
                    where: 'id = ?',
                    whereArgs: [card['id']],
                  );
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Cartão atualizado com sucesso!")),
                );
                Navigator.pop(context);
                _loadCards();
              },
            ),
          ],
        );
      },
    );
  }

  static InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white),
      filled: true,
      fillColor: const Color(0xFF001070),
      contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
    );
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
          "Métodos de pagamento",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Column(
          children: [
            if (_cards.isEmpty) ...[
              const Spacer(),
              const Text(
                "Nenhum método de pagamento encontrado",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "Você pode adicionar ou editar seus métodos de pagamento",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 32),
            ] else ...[
              const Text(
                "Cartões Salvos",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _cards.length,
                  itemBuilder: (context, index) {
                    final card = _cards[index];
                    final numero = (card['numero_cartao'] ?? '').toString();
                    final ultimos4 = numero.length >= 4
                        ? numero.substring(numero.length - 4)
                        : numero;

                    return Container(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF3A57E8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        leading: const Icon(Icons.credit_card, color: Colors.white, size: 32),
                        title: Text(
                          "**** **** **** $ultimos4",
                          style: const TextStyle(color: Colors.white, fontSize: 16),
                        ),
                        subtitle: Text(
                          card['nome_titular'] ?? '',
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.white),
                              onPressed: () => _editCard(card),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.redAccent),
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF001C92),
                                    title: const Text("Excluir Cartão", style: TextStyle(color: Colors.white)),
                                    content: const Text(
                                      "Tem certeza que deseja excluir este cartão?",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text("Cancelar", style: TextStyle(color: Colors.white)),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _deleteCard(card['id']);
                                        },
                                        child: const Text("Excluir", style: TextStyle(color: Colors.redAccent)),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: 24),
            GestureDetector(
              onTap: () async {
                final added = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MetodoPagamentoPage()),
                );

                if (added == true) {
                  _loadCards();
                }
              },
              child: Container(
                width: double.infinity,
                height: 120,
                decoration: BoxDecoration(
                  color: const Color(0xFF3A57E8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.add_circle_outline, color: Colors.white, size: 36),
                      SizedBox(height: 8),
                      Text(
                        "Adicionar método de pagamento",
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
