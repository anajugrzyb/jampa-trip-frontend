import 'dart:io';
import 'package:flutter/material.dart';
import 'reservation_page.dart';

class AdViewPage extends StatelessWidget {
  final Map<String, dynamic> tour;

  const AdViewPage({super.key, required this.tour});

  Widget _buildImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.file(
          file,
          width: double.infinity,
          height: 220,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: 220,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(16),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported,
            size: 60, color: Colors.white),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              "$label: ${value ?? '-'}",
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagens = (tour['imagens'] as String?)?.split(',') ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: Text(
          tour['nome'] ?? "Detalhes do Passeio",
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: const Color(0xFF00008B),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (imagens.isNotEmpty)
              SizedBox(
                height: 220,
                child: PageView.builder(
                  itemCount: imagens.length,
                  controller: PageController(viewportFraction: 0.9),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _buildImage(imagens[index]),
                    );
                  },
                ),
              ),
            const SizedBox(height: 20),

            Card(
              color: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour['nome'] ?? '',
                      style: TextStyle( 
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[900],
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildInfoRow(Icons.departure_board, "Saída", tour['saida']),
                    _buildInfoRow(Icons.flag, "Chegada", tour['chegada']),
                    _buildInfoRow(
                        Icons.people, "Qtd pessoas", tour['qtd_pessoas']),
                    const Divider(height: 24, thickness: 1),

                    Row(
                      children: [
                        const Icon(Icons.attach_money,
                            color: Colors.green, size: 22),
                        const SizedBox(width: 6),
                        Text(
                          "Preço: R\$ ${tour['preco']?.toStringAsFixed(2) ?? '0,00'}",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Text(
                      tour['info'] ?? "Sem informações adicionais.",
                      style: const TextStyle(fontSize: 16, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReservationPage(tour: tour),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.shopping_cart_checkout,
                    size: 22, color: Colors.white),
                label: const Text(
                  "Reservar Passeio",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
