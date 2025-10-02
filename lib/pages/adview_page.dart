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
        child: const Icon(Icons.image_not_supported, size: 60, color: Colors.white),
      );
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String? value) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue[700]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            "$label: ${value ?? '-'}",
            style: const TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final imagens = (tour['imagens'] as String?)?.split(',') ?? [];

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: Text(
          tour['nome'] ?? "Detalhes",
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carrossel de imagens
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

            // Nome do passeio
            Text(
              tour['nome'] ?? '',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue[900],
              ),
            ),
            const SizedBox(height: 12),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _buildInfoRow(Icons.calendar_today, "Datas disponíveis", tour['datas']),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.departure_board, "Saída", tour['saida']),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.flag, "Chegada", tour['chegada']),
                    const SizedBox(height: 10),
                    _buildInfoRow(Icons.people, "Qtd pessoas", tour['qtd_pessoas']),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              "Preço: R\$ ${tour['preco']?.toStringAsFixed(2) ?? '0,00'}",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),

            Text(
              tour['info'] ?? "Sem informações adicionais.",
              style: const TextStyle(fontSize: 16, height: 1.5),
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
                  backgroundColor: Colors.blue[800],
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
                icon: const Icon(Icons.shopping_cart_checkout, size: 22),
                label: const Text(
                  "Reservar Passeio",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
