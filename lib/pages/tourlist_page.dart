import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';

class TourListPage extends StatefulWidget {
  final String query; 
  const TourListPage({super.key, required this.query});

  @override
  State<TourListPage> createState() => _TourListPageState();
}

class _TourListPageState extends State<TourListPage> {
  List<Map<String, dynamic>> _tours = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchTours();
  }

  Future<void> _searchTours() async {
    final db = DBHelper();
    final tours = await db.getTours();
    final query = widget.query.toLowerCase();

    setState(() {
      _tours = tours.where((tour) {
        final nome = (tour['nome'] ?? '').toLowerCase();
        final saida = (tour['saida'] ?? '').toLowerCase();
        final chegada = (tour['chegada'] ?? '').toLowerCase();
        return nome.contains(query) || saida.contains(query) || chegada.contains(query);
      }).toList();
      _isLoading = false;
    });
  }

  Widget _buildImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return Image.file(
        file,
        height: 180,
        width: double.infinity,
        fit: BoxFit.cover,
      );
    } else {
      return Container(
        height: 180,
        color: Colors.grey[300],
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 50),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Resultados para \"${widget.query}\""),
        backgroundColor: Colors.blue[800],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _tours.isEmpty
              ? const Center(
                  child: Text(
                    "Nenhum passeio encontrado!",
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _tours.length,
                  itemBuilder: (context, index) {
                    final tour = _tours[index];
                    final imagens = (tour['imagens'] as List<dynamic>).cast<String>();
                    int currentPage = 0;
                    final PageController pageController = PageController();

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (imagens.isNotEmpty)
                            StatefulBuilder(builder: (context, setStateCard) {
                              return Column(
                                children: [
                                  SizedBox(
                                    height: 180,
                                    child: PageView(
                                      controller: pageController,
                                      onPageChanged: (index) {
                                        setStateCard(() {
                                          currentPage = index;
                                        });
                                      },
                                      children: imagens.map((path) => _buildImage(path)).toList(),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(imagens.length, (i) {
                                      return Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 3),
                                        width: currentPage == i ? 10 : 6,
                                        height: currentPage == i ? 10 : 6,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: currentPage == i
                                              ? Colors.blue[800]
                                              : Colors.grey[400],
                                        ),
                                      );
                                    }),
                                  ),
                                ],
                              );
                            }),
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  tour['nome'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    const Icon(Icons.departure_board, size: 18, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("Saída: ${tour['saida']}"),
                                    const SizedBox(width: 16),
                                    const Icon(Icons.flag, size: 18, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Text("Chegada: ${tour['chegada']}"),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Preço: R\$ ${tour['preco']}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.blueAccent,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[800],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      padding: const EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    child: const Text("Ver Detalhes"),
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
}

