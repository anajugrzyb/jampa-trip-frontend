import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'feedback_page.dart';

class MyReservationsPage extends StatefulWidget {
  final String? userEmail;

  const MyReservationsPage({super.key, this.userEmail});

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
        'status': (reserva['status'] ?? 'pendente').toString(),
      };
       }).where((reserva) {
      final status = reserva['status']?.toLowerCase() ?? 'pendente';
      return status == 'aprovado' || status == 'pendente';
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

 ImageProvider _buildImageProvider(String? paths) {
    if (paths == null || paths.isEmpty) {
      return const AssetImage("lib/assets/images/no_image.png");
    }

     final imagePaths = paths
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

     if (imagePaths.isEmpty) {
      return const AssetImage("lib/assets/images/no_image.png");
    }

    final firstImage = imagePaths.first;

    if (firstImage.startsWith('http')) return NetworkImage(firstImage);

    final file = File(firstImage);
    return file.existsSync()
        ? FileImage(file)
        : const AssetImage("lib/assets/images/no_image.png");
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'aprovado':
        return Colors.green;
      case 'recusado':
        return Colors.redAccent;
      default:
        return Colors.amber;
    }
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
                final status = (reserva['status'] ?? 'pendente').toString();
                final double valorTotal =
                    (reserva['valor_total'] as num?)?.toDouble() ?? 0;

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
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    reserva['tour_nome'] ?? 'Passeio',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF001E6C),
                                    ),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: _statusColor(status).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.circle,
                                        size: 10,
                                        color: _statusColor(status),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        status.toUpperCase(),
                                        style: TextStyle(
                                          color: _statusColor(status),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                               status == 'aprovado'
                                  ? 'Passeio aprovado pela empresa'
                                  : 'Aguardando aprovação da empresa',
                              style: TextStyle(
                                color: _statusColor(status),
                                fontWeight: FontWeight.w500,
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
                              "Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF001E6C),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: Wrap(
                                spacing: 8,
                                children: [
                                  if (status.toLowerCase() == 'aprovado')
                                    TextButton.icon(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                             builder: (_) => FeedbackPage(
                                          companyName:
                                              reserva['empresa'] as String?,
                                          tourName:
                                              reserva['tour_nome'] as String?,
                                          userEmail: widget.userEmail,
                                        ),
                                      ),
                                    );
                                  },
                                      icon: const Icon(Icons.star_rate,
                                          color: Color(0xFF00008B)),
                                      label: const Text(
                                        "Deixar feedback",
                                        style:
                                            TextStyle(color: Color(0xFF00008B)),
                                      ),
                                    ),
                                  TextButton.icon(
                                    onPressed: () =>
                                        _showCancelDialog(reserva['id']),
                                    icon: const Icon(Icons.cancel,
                                        color: Colors.redAccent),
                                    label: const Text(
                                      "Cancelar",
                                      style: TextStyle(color: Colors.redAccent),
                                    ),
                                  ),
                                ],
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
