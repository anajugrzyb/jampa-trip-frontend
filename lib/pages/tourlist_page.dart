import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'adview_page.dart';
import 'company_page.dart';

class TourListPage extends StatefulWidget {
  final String query;
  const TourListPage({super.key, required this.query});

  @override
  State<TourListPage> createState() => _TourListPageState();
}

class _TourListPageState extends State<TourListPage>
    with SingleTickerProviderStateMixin {
  List<Map<String, dynamic>> _tours = [];
  List<Map<String, dynamic>> _companies = [];
  bool _isLoading = true;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchData();
  }

  Future<void> _searchData() async {
    final db = DBHelper();
    final tours = await db.getTours();
    final companies = await db.db.then((dbClient) => dbClient.query('companies'));

    final query = widget.query.toLowerCase();

    final filteredTours = tours.where((tour) {
      if (query.isEmpty) return true;
      final nome = (tour['nome'] ?? '').toLowerCase();
      final local = (tour['local'] ?? '').toLowerCase();
      return nome.contains(query) || local.contains(query);
    }).toList();

    final filteredCompanies = companies.where((company) {
      final companyName = (company['company_name'] as String?)?.toLowerCase() ?? '';
      final hasTour = filteredTours.any((tour) {
        final empresa = (tour['empresa'] ?? '').toLowerCase();
        return empresa.contains(companyName);
      });
      return companyName.contains(query) || hasTour;
    }).toList();

    setState(() {
      _tours = filteredTours;
      _companies = filteredCompanies;
      _isLoading = false;
    });
  }

  Widget _buildTourCard(Map<String, dynamic> tour) {
    final imagens = (tour['imagens'] as String?)?.split(',') ?? [];
    final empresa = tour['empresa'] ?? 'Sem empresa';
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
          if (imagens.isNotEmpty && imagens.first.isNotEmpty)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.file(
                File(imagens.first),
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            )
          else
            Container(
              height: 180,
              color: Colors.grey[300],
              alignment: Alignment.center,
              child: const Icon(Icons.image_not_supported, size: 50),
            ),
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
                    const Icon(Icons.apartment, size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(empresa),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.location_on,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(tour['local'] ?? ''),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  "R\$ ${tour['preco'] ?? '0,00'}",
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
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdViewPage(tour: tour),
                        ),
                      );
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
  }

  Widget _buildCompanyCard(Map<String, dynamic> company) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CompanyPage(company: company),
          ),
        );
      },
      child: Container(
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
        child: Row(
          children: [
            Container(
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(Icons.store, size: 40, color: Colors.blue),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company['company_name'] ?? '',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: const [
                        Icon(Icons.star, color: Colors.amber, size: 18),
                        SizedBox(width: 4),
                        Text(
                          "4.8",
                          style: TextStyle(fontSize: 14),
                        ),
                        SizedBox(width: 6),
                        Text("• 30-40 min",
                            style: TextStyle(
                                color: Colors.grey, fontSize: 13)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Toque para ver os passeios",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.query.isEmpty
            ? "Explorar"
            : "Resultados para \"${widget.query}\""),
        backgroundColor: Colors.blue[800],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: "Passeios"),
            Tab(text: "Empresas"),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _tours.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhum passeio encontrado!",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _tours.length,
                        itemBuilder: (context, index) =>
                            _buildTourCard(_tours[index]),
                      ),

                _companies.isEmpty
                    ? const Center(
                        child: Text(
                          "Nenhuma empresa encontrada!",
                          style:
                              TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _companies.length,
                        itemBuilder: (context, index) =>
                            _buildCompanyCard(_companies[index]),
                      ),
              ],
            ),
    );
  }
}
