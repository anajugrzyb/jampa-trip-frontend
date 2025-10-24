import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'pixpayment_page.dart';
import 'cardregister_page.dart';
import 'reservationconfirmed_page.dart';

class MetodoPagamentoPage extends StatefulWidget {
  final double valorTotal;
  final Map<String, dynamic> reserva;

  const MetodoPagamentoPage({super.key, required this.valorTotal, required this.reserva});

  @override
  State<MetodoPagamentoPage> createState() => _MetodoPagamentoPageState();
}

class _MetodoPagamentoPageState extends State<MetodoPagamentoPage> {
  List<Map<String, dynamic>> _cards = [];
  int? _selectedCardId;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final db = DBHelper();
    final cards = await db.getCards();
    setState(() {
      _cards = cards;
    });
  }

  void _goToCardRegister() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CardRegisterPage(valorTotal: widget.valorTotal, reserva: widget.reserva),
      ),
    );
    _loadCards();
  }

  void _selectCard(int cardId) {
    setState(() {
      _selectedCardId = _selectedCardId == cardId ? null : cardId;
    });
  }

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
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF001E6C),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "Valor a ser cobrado: R\$ ${widget.valorTotal.toStringAsFixed(2)}",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Escolha uma forma de pagamento:",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),

            _metodoItem(
              nome: "Pix",
              iconPath: "lib/assets/images/pix.png",
              context: context,
              destaque: true,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PixPaymentPage(
                      valorTotal: widget.valorTotal,
                    ),
                  ),
                );
              },
            ),

            _metodoItem(
              nome: "Adicionar novo cartão",
              iconPath: "lib/assets/images/cartao.jpg",
              context: context,
              onTap: _goToCardRegister,
            ),

            const SizedBox(height: 25),

            Expanded(
              child: _cards.isEmpty
                  ? const Center(
                      child: Text(
                        "Nenhum cartão cadastrado ainda.",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView(
                      children: [
                        const Text(
                          "Cartões cadastrados:",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ..._cards.map((card) {
                          return Dismissible(
                            key: Key(card['id'].toString()),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.redAccent,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.delete,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),
                            onDismissed: (direction) async {
                              final db = DBHelper();
                              await db.deleteCard(card['id']);
                              setState(() {
                                _cards.removeWhere(
                                    (c) => c['id'] == card['id']);
                              });

                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content:
                                      Text("Cartão removido com sucesso."),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: _cardItem(card),
                          );
                        }).toList(),
                      ],
                    ),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: _selectedCardId == null
                  ? null
                  : () {
                      final selectedCard = _cards.firstWhere(
                        (card) => card['id'] == _selectedCardId,
                      );

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Pagamento de R\$ ${widget.valorTotal.toStringAsFixed(2)} aprovado com o cartão terminando em ${selectedCard['numero_cartao'].toString().substring(selectedCard['numero_cartao'].toString().length - 4)}",
                          ),
                        ),
                      );

                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ReservationConfirmedPage(reserva: widget.reserva),
                          ),
                        );
                      });
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightBlueAccent,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Confirmar pagamento",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
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
    required VoidCallback onTap,
    bool destaque = false,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
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
            Icon(Icons.chevron_right, color: Colors.blue[800]),
          ],
        ),
      ),
    );
  }

  Widget _cardItem(Map<String, dynamic> card) {
    final id = card['id'] as int;
    final number = card['numero_cartao'] ?? '';
    final last4 =
        number.length >= 4 ? number.substring(number.length - 4) : number;
    final holder = card['nome_titular'] ?? '';
    final month = card['mes'] ?? '--';
    final year = card['ano'] ?? '--';

    final isSelected = _selectedCardId == id;

    return InkWell(
      onTap: () => _selectCard(id),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0026A1) : const Color(0xFF001E6C),
          borderRadius: BorderRadius.circular(14),
          border: isSelected
              ? Border.all(color: Colors.lightBlueAccent, width: 2)
              : null,
        ),
        child: Row(
          children: [
            const Icon(Icons.credit_card, color: Colors.white, size: 40),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "**** **** **** $last4",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      letterSpacing: 1.5,
                    ),
                  ),
                  Text(
                    holder,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    "Val: $month/$year",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_off,
              color: isSelected ? Colors.lightBlueAccent : Colors.white,
              size: 26,
            ),
          ],
        ),
      ),
    );
  }
}
