import 'dart:io';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'account_page.dart';
import 'company_page.dart';
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

  final _pageController = PageController(viewportFraction: 0.85);

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadUserImage();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final db = DBHelper();
    final tours = await db.getTours();
    final companies = await db.getCompanies();

    setState(() {
      final sortedTours = List<Map<String, dynamic>>.from(tours)
        ..sort((a, b) => ((b['id'] ?? 0) as int).compareTo((a['id'] ?? 0) as int));

      _recentTours = sortedTours.take(5).toList();
      _companies = companies;
    });
  }

  Future<void> _loadUserImage() async {
    final db = DBHelper();
    final imagePath = await db.getUserImage(widget.userEmail);
    setState(() {
      _userImage = (imagePath != null && File(imagePath).existsSync())
          ? File(imagePath)
          : null;
    });
  }

    String? _extractPrimaryImage(String? rawPath) {
    if (rawPath == null || rawPath.isEmpty) return null;

    final paths = rawPath
        .split(',')
        .map((p) => p.trim())
        .where((p) => p.isNotEmpty)
        .toList();

    return paths.isNotEmpty ? paths.first : null;
  }

  ImageProvider _buildImageProvider(String? rawPath) {
    final path = _extractPrimaryImage(rawPath);

    if (path == null || path.isEmpty) {
       return const AssetImage("lib/assets/images/planeta.png");
    }
    return (path.contains('/data/') || path.contains('/storage/'))
        ? FileImage(File(path))
        : AssetImage(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            _buildSearchField(context),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
                ),
                child: RefreshIndicator(
                  onRefresh: () async {
                    await _loadData();
                    await _loadUserImage();
                  },
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
      bottomNavigationBar: _buildBottomBar(context),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () async {
              final updated = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => AccountPage(
                    userName: widget.userName,
                    userEmail: widget.userEmail,
                  ),
                ),
              );
              if (updated == true) _loadUserImage();
            },
            child: CircleAvatar(
              radius: 35,
              backgroundImage: _userImage != null
                  ? FileImage(_userImage!)
                  : const AssetImage("assets/profile.jpg") as ImageProvider,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              "Olá, ${widget.userName} 👋\nExplore o melhor de João Pessoa!",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                height: 1.4,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: TextField(
        onSubmitted: (value) {
          if (value.trim().isNotEmpty) {
            Navigator.push(
              context,
              _buildFadeRoute(TourListPage(query: value.trim())),
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
      return const Padding(
        padding: EdgeInsets.all(20),
        child: Center(child: Text("Nenhum anúncio recente encontrado.")),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 230,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _recentTours.length,
            itemBuilder: (context, index) {
              final tour = _recentTours[index];
              return AnimatedBuilder(
                animation: _pageController,
                builder: (context, child) {
                  double scale = 1.0;
                  if (_pageController.hasClients &&
                      _pageController.position.haveDimensions) {
                    final page = _pageController.page ?? 0.0;
                    scale = (1 - ((page - index).abs() * 0.2)).clamp(0.8, 1.0);
                  }
                  return Transform.scale(
                    scale: scale,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          _buildFadeRoute(TourListPage(query: tour["nome"])),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(18),
                          image: DecorationImage(
                            image: _buildImageProvider(tour["imagens"]),
                            fit: BoxFit.cover,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 6,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            gradient: const LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [Colors.black54, Colors.transparent],
                            ),
                          ),
                          padding: const EdgeInsets.all(12),
                          alignment: Alignment.bottomLeft,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tour["nome"] ?? "Passeio",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                "R\$ ${tour["preco"] ?? "0,00"}",
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        SmoothPageIndicator(
          controller: _pageController,
          count: _recentTours.length,
          effect: ExpandingDotsEffect(
            dotHeight: 8,
            dotWidth: 8,
            spacing: 6,
            dotColor: Colors.grey.shade300,
            activeDotColor: const Color(0xFF001E6C),
          ),
        ),
      ],
    );
  }

Widget _buildCompanyList() {
  if (_companies.isEmpty) {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(child: Text("Nenhuma empresa cadastrada.")),
    );
  }

  return ListView.separated(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: _companies.length,
    separatorBuilder: (context, index) => const SizedBox(height: 10), 
    itemBuilder: (context, index) {
      final company = _companies[index];
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ListTile(
          leading: CircleAvatar(
            radius: 28,
            backgroundImage: _buildImageProvider(company["logo"]),
          ),
          title: Text(
            company["company_name"] ?? "Empresa",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF001E6C),
            ),
          ),
          onTap: () {
            Navigator.push(
              context,
              _buildFadeRoute(CompanyPage(company: company)),
            );
          },
        ),
      );
    },
  );
}


  Widget _buildBottomBar(BuildContext context) {
    return Container(
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
              _buildFadeRoute(TourListPage(query: '')),
            );
          }),
          _buildNavButton(Icons.person, "Perfil", false, () async {
            final updated = await Navigator.push(
              context,
              _buildFadeRoute(
                AccountPage(
                  userName: widget.userName,
                  userEmail: widget.userEmail,
                ),
              ),
            );
            if (updated == true) _loadUserImage();
          }),
        ],
      ),
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

  Route _buildFadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) => FadeTransition(
        opacity: animation,
        child: child,
      ),
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
