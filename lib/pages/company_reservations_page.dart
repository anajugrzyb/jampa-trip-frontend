import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';

class CompanyReservationsPage extends StatefulWidget {
  final String companyName;

  const CompanyReservationsPage({super.key, required this.companyName});

  @override
  State<CompanyReservationsPage> createState() =>
      _CompanyReservationsPageState();
}

class _CompanyReservationsPageState extends State<CompanyReservationsPage> {
  List<Map<String, dynamic>> _reservations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReservations();
  }

  Future<void> _loadReservations() async {
    final db = DBHelper();
    final reservas = await db.getReservasPorEmpresa(widget.companyName);
    final tours = await db.getTours(empresa: widget.companyName);

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
        'local': tour['local'],
      };
    }).toList();

    setState(() {
      _reservations = reservasComDetalhes;
      _isLoading = false;
    });
  }

  ImageProvider _buildImageProvider(String? paths) {
    if (paths == null || paths.isEmpty) {
      return const AssetImage("lib/assets/images/no_image.png");
    }

    final firstImage = paths.split(',').firstWhere(
          (p) => p.trim().isNotEmpty,
          orElse: () => '',
        );

    if (firstImage.isEmpty) {
      return const AssetImage("lib/assets/images/no_image.png");
    }

    final file = File(firstImage.trim());
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

  Future<void> _atualizarStatus(int id, String status) async {
    final db = DBHelper();
    await db.updateReservaStatus(id, status);
    await _loadReservations();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reserva ${status.toLowerCase()} com sucesso!'),
        backgroundColor: _statusColor(status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text(
          "Reservas Recebidas",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        backgroundColor: const Color(0xFF00008B),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.white),
            )
          : _reservations.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhuma reserva encontrada para seus passeios.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
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
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                        horizontal: 10,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color:
                                            _statusColor(status).withOpacity(0.12),
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
                                if (reserva['local'] != null)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 8.0),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.place,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          reserva['local'],
                                          style: const TextStyle(
                                              color: Colors.black87),
                                        )
                                      ],
                                    ),
                                  ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.calendar_today,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          reserva['data_reserva'] ?? '-',
                                          style:
                                              const TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        const Icon(Icons.people_alt,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          "${reserva['qtd_pessoas']} pessoas",
                                          style:
                                              const TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        const Icon(Icons.access_time,
                                            size: 18, color: Colors.black54),
                                        const SizedBox(width: 6),
                                        Text(
                                          "Saída: ${reserva['saida'] ?? '-'}",
                                          style:
                                              const TextStyle(color: Colors.black87),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "Retorno: ${reserva['chegada'] ?? '-'}",
                                      style:
                                          const TextStyle(color: Colors.black87),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "Cliente: ${reserva['nome']} | Tel: ${reserva['telefone']}",
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Valor Total: R\$ ${valorTotal.toStringAsFixed(2)}",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF001E6C),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  "Observações: ${reserva['observacoes']?.toString().isEmpty == false ? reserva['observacoes'] : 'Nenhuma'}",
                                  style: const TextStyle(color: Colors.black87),
                                ),
                                const SizedBox(height: 12),
                                if (status.toLowerCase() == 'pendente')
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () =>
                                              _atualizarStatus(reserva['id'], 'aprovado'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.check, color: Colors.white),
                                          label: const Text(
                                            "Aprovar",
                                            style: TextStyle(color: Colors.white),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                          onPressed: () =>
                                              _atualizarStatus(reserva['id'], 'recusado'),
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor: Colors.redAccent,
                                            side: const BorderSide(color: Colors.redAccent),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                          ),
                                          icon: const Icon(Icons.close),
                                          label: const Text("Recusar"),
                                        ),
                                      ),
                                    ],
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
}