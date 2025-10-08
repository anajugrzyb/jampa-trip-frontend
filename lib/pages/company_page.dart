import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'adview_page.dart';

class CompanyPage extends StatefulWidget {
  final Map<String, dynamic> company;

  const CompanyPage({super.key, required this.company});

  @override
  State<CompanyPage> createState() => _CompanyPageState();
}

class _CompanyPageState extends State<CompanyPage> {
  List<Map<String, dynamic>> _tours = [];

  @override
  void initState() {
    super.initState();
    _carregarAnuncios();
  }

  Future<void> _carregarAnuncios() async {
    final db = DBHelper();
    final data = await db.getTours(empresa: widget.company['company_name']);
    setState(() {
      _tours = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    final empresa = widget.company;

    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            backgroundColor: const Color(0xFF00008B),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  empresa['imagem'] != null && empresa['imagem'].isNotEmpty
                      ? Image.file(
                          File(empresa['imagem']),
                          fit: BoxFit.cover,
                        )
                      : Container(color: Colors.blue[700]),
                  Container(color: Colors.black.withOpacity(0.5)),
                  Align(
                    alignment: Alignment.bottomLeft,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CircleAvatar(
                            radius: 36,
                            backgroundColor: Colors.white,
                            backgroundImage: empresa['imagem'] != null &&
                                    empresa['imagem'].isNotEmpty
                                ? FileImage(File(empresa['imagem']))
                                : const AssetImage(
                                        "assets/company_placeholder.png")
                                    as ImageProvider,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  empresa['company_name'] ?? 'Empresa',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: const [
                                    Icon(Icons.star,
                                        color: Colors.amber, size: 18),
                                    SizedBox(width: 4),
                                    Text(
                                      "4.8",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Container(
              width: double.infinity,
              color: Colors.blue[800],
              padding: const EdgeInsets.all(16),
              child: Text(
                empresa['descricao'] ??
                    'Explore os melhores passeios e experiências desta empresa!',
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                  height: 1.5,
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              child: const Text(
                "Passeios disponíveis",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _tours.length,
                itemBuilder: (context, index) {
                  final t = _tours[index];
                  final imagens = (t['imagens'] as String?)?.split(',') ?? [];

                  return Container(
                    width: 220,
                    margin: const EdgeInsets.only(left: 16, right: 8, bottom: 16),
                    decoration: BoxDecoration(
                      color: Colors.blue[700],
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: imagens.isNotEmpty && imagens.first.isNotEmpty
                              ? Image.file(
                                  File(imagens.first),
                                  width: double.infinity,
                                  height: 140,
                                  fit: BoxFit.cover,
                                )
                              : Container(
                                  height: 140,
                                  color: Colors.blue[600],
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.image_not_supported,
                                      size: 40, color: Colors.white70),
                                ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  t['nome'] ?? 'Passeio',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  t['local'] ?? '',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  "R\$ ${t['preco'] ?? '0,00'}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.lightBlueAccent,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              AdViewPage(tour: t),
                                        ),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.blue[400],
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8),
                                    ),
                                    child: const Text(
                                      "Ver mais",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
