import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';

class MyReservationsPage extends StatefulWidget {
  const MyReservationsPage({super.key});

  @override
  State<MyReservationsPage> createState() => _MyReservationsPageState();
}

class _MyReservationsPageState extends State<MyReservationsPage> {
  List<Map<String, dynamic>> _reservations = [];

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final db = DBHelper();
    final reservas = await db.getReservas();

    // 🔍 Juntando com a tabela de tours (para pegar imagens e horários)
    final tours = await db.getTours();
    final reservasComDetalhes = reservas.map((reserva) {
      final tour = tours.firstWhere(
        (t) => t['id'] == reserva['tour_id'],
        orElse: () => {},
      );
      return {
        ...reserva,
        'imagem': tour['imagens'],
        'saida': tour['saida'],
        'chegada': tour['chegada'],
      };
    }).toList();

    setState(() {
      _reservations = reservasComDetalhes;
    });
  }

  Future<void> _cancelReservation(int id) async {
    final db = DBHelper();
    await db.deleteReserva(id);
    _loadReservations();
  }

  ImageProvider _buildImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage("lib/assets/images/no_image.png");
    }

    if (path.startsWith('http')) return NetworkImage(path);

    final file = File(path);
    return file.existsSync()
        ? FileImage(file)
        : const AssetImage("lib/assets/images/no_image.png");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          "Minhas Reservas",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF00008B),
        centerTitle: true,
      ),
      body: _reservations.isEmpty
          ? const Center(
              child: Text(
                "Você ainda não possui reservas.",
                style: TextStyle(color: Colors.black54, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _reservations.length,
              itemBuilder: (context, index) {
                final reserva = _reservations[index];

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  elevation: 4,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🖼️ Imagem do passeio
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image(
                          image: _buildImageProvider(reserva['imagem']),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reserva['tour_nome'] ?? 'Passeio',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001E6C),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 18, color: Colors.black54),
                                Text(
                                  reserva['data_reserva'] ?? '-',
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(width: 12),
                                const Icon(Icons.people_alt,
                                    size: 18, color: Colors.black54),
                                Text(
                                  "${reserva['qtd_pessoas']} pessoas",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Icon(Icons.access_time,
                                    size: 18, color: Colors.black54),
                                Text(
                                  "Saída: ${reserva['saida'] ?? '-'}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                Text(
                                  "Retorno: ${reserva['chegada'] ?? '-'}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "Valor Total: R\$ ${reserva['valor_total']?.toStringAsFixed(2) ?? '0.00'}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001E6C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton.icon(
                                onPressed: () =>
                                    _showCancelDialog(reserva['id']),
                                icon: const Icon(Icons.cancel,
                                    color: Colors.redAccent),
                                label: const Text(
                                  "Cancelar",
                                  style: TextStyle(color: Colors.redAccent),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  void _showCancelDialog(int id) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Cancelar Reserva"),
        content: const Text("Tem certeza que deseja cancelar esta reserva?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Não"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _cancelReservation(id);
            },
            child: const Text("Sim, cancelar"),
          ),
        ],
      ),
    );
  }
}
