import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/db_helper.dart';
import 'feedback_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Map<String, dynamic>> _completedReservations = [];

  @override
  void initState() {
    super.initState();
    _loadCompletedReservations();
  }

  Future<void> _loadCompletedReservations() async {
    final db = DBHelper();
    final reservas = await db.getReservas();
    final tours = await db.getTours();

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final historico = reservas.map((reserva) {
      final tour = tours.firstWhere(
        (t) => t['id'] == reserva['tour_id'],
        orElse: () => <String, dynamic>{},
      );

      return {
        ...reserva,
        'imagem': tour['imagens'],
        'saida': tour['saida'],
        'chegada': tour['chegada'],
      };
    }).where((reserva) {
      final status = (reserva['status'] ?? '').toString().toLowerCase();
      if (status != 'aprovado') return false;

      final dataStr = reserva['data_reserva'] as String?;
      if (dataStr == null || dataStr.isEmpty) return false;

      try {
        final data = DateFormat('dd/MM/yyyy').parse(dataStr);
        final dataPasseio = DateTime(data.year, data.month, data.day);
        return dataPasseio.isBefore(todayDate);
      } catch (_) {
        return false;
      }
    }).toList()
      ..sort((a, b) {
        final dataA = DateFormat('dd/MM/yyyy').parse(a['data_reserva']);
        final dataB = DateFormat('dd/MM/yyyy').parse(b['data_reserva']);
        return dataB.compareTo(dataA);
      });

    setState(() {
      _completedReservations = historico;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00008B),
        title: const Text('Histórico de Passeios'),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadCompletedReservations,
        child: _completedReservations.isEmpty
            ? ListView(
                children: const [
                  SizedBox(height: 120),
                  Icon(Icons.history_rounded,
                      size: 64, color: Colors.black38),
                  SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Nenhum passeio realizado ainda.',
                      style: TextStyle(
                        color: Colors.black54,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: _completedReservations.length,
                itemBuilder: (context, index) {
                  final reserva = _completedReservations[index];
                  final valorTotal =
                      (reserva['valor_total'] as num?)?.toDouble() ?? 0.0;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                              child: Image(
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                                image: _buildImageProvider(
                                    reserva['imagem'] as String?),
                              ),
                            ),
                            Positioned(
                              top: 12,
                              right: 12,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: const [
                                    Icon(Icons.check_circle,
                                        size: 18, color: Colors.green),
                                    SizedBox(width: 6),
                                    Text(
                                      'Realizado',
                                      style: TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                reserva['tour_nome'] ?? 'Passeio',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001E6C),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reserva['empresa'] ?? 'Empresa não informada',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    reserva['data_reserva'] ?? '-/-/-',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.access_time,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Saída: ${reserva['saida'] ?? '-'}  •  Retorno: ${reserva['chegada'] ?? '-'}',
                                      style: const TextStyle(
                                          color: Colors.black87),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.people,
                                      size: 18, color: Colors.black54),
                                  const SizedBox(width: 8),
                                  Text(
                                    '${reserva['qtd_pessoas'] ?? 0} pessoas',
                                    style:
                                        const TextStyle(color: Colors.black87),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Valor total pago: R\$ ${valorTotal.toStringAsFixed(2)}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF001E6C),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton.icon(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => FeedbackPage(
                                          companyName:
                                              reserva['empresa'] as String?,
                                          tourName:
                                              reserva['tour_nome'] as String?,
                                        ),
                                      ),
                                    );
                                  },
                                  icon: const Icon(Icons.rate_review,
                                      color: Color(0xFF00008B)),
                                  label: const Text(
                                    'Avaliar passeio',
                                    style: TextStyle(color: Color(0xFF00008B)),
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
      ),
    );
  }
}