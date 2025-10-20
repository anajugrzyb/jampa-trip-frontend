import 'dart:io';
import 'package:flutter/material.dart';
import 'account_page.dart';
import 'tourlist_page.dart';
import '../data/db_helper.dart';

class HomePage extends StatefulWidget {
  final String userName;
  final String userEmail;

  const HomePage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> _recentTours = [];
  List<Map<String, dynamic>> _companies = [];
  File? _userImage; 

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserImage();
  }

  Future<void> _loadData() async {
    final db = DBHelper();
    final tours = await db.getTours();
    final companies = await db.getCompanies();

    setState(() {
      _recentTours = tours.reversed.take(5).toList();
      _companies = companies;
    });
  }

  Future<void> _loadUserImage() async {
    final db = DBHelper();
    final imagePath = await db.getUserImage(widget.userEmail);

    if (imagePath != null && File(imagePath).existsSync()) {
      setState(() {
        _userImage = File(imagePath);
      });
    }
  }

  ImageProvider _buildImageProvider(String? path) {
    if (path == null || path.isEmpty) {
      return const AssetImage("lib/assets/images/default.jpg");
    }

    if (path.contains('/data/') || path.contains('/storage/')) {
      return FileImage(File(path));
    }

    return AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 35,
                    backgroundImage: _userImage != null
                        ? FileImage(_userImage!)
                        : const AssetImage("lib/assets/images/profile.png")
                            as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      "Olá, ${widget.userName} 👋\nExplore o melhor de João Pessoa!",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        height: 1.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TourListPage(query: value.trim()),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "Buscar passeios ou empresas...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.15),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(26),
                    topRight: Radius.circular(26),
                  ),
                ),
                child: RefreshIndicator(
                  onRefresh: _loadData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 80),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle("Anúncios Recentes"),
                        _buildRecentTours(),
                        _buildSectionTitle("Empresas Parceiras"),
                        _buildCompanyList(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),

      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF001E6C),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, -2)),
          ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavButton(Icons.home, "Início", true, () {}),
            _buildNavButton(Icons.explore, "Explorar", false, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TourListPage(query: '')),
              );
            }),
            _buildNavButton(Icons.person, "Perfil", false, () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountPage(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                  ),
                ),
              );
              _loadUserImage();
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Color(0xFF001E6C),
        ),
      ),
    );
  }

  Widget _buildRecentTours() {
    if (_recentTours.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Nenhum anúncio recente encontrado."),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _recentTours.length,
        itemBuilder: (context, index) {
          final tour = _recentTours[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TourListPage(query: tour["nome"])),
              );
            },
            child: Container(
              width: 180,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: _buildImageProvider(tour["imagens"]),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: const LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black54, Colors.transparent],
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tour["nome"] ?? "Passeio",
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 15),
                    ),
                    Text(
                      "R\$ ${tour["preco"] ?? "0,00"}",
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCompanyList() {
    if (_companies.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Text("Nenhuma empresa cadastrada."),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _companies.length,
      itemBuilder: (context, index) {
        final company = _companies[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: _buildImageProvider(company["logo"]),
          ),
          title: Text(
            company["company_name"] ?? "Empresa",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            "Avaliação: ${company["avaliacao"]?.toStringAsFixed(1) ?? "N/A"} ⭐",
            style: const TextStyle(color: Colors.grey),
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => TourListPage(query: company["company_name"]),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNavButton(
      IconData icon, String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: isActive ? Colors.lightBlueAccent : Colors.white, size: 28),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.lightBlueAccent : Colors.white70,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
