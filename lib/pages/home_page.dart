import 'package:flutter/material.dart';
import 'account_page.dart';
import 'tourlist_page.dart'; 

class HomePage extends StatelessWidget {
  final String userName; 
  const HomePage({super.key, required this.userName});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: const Color(0xFF000080),
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage("lib/assets/images/profile.png"), 
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Seja bem vindo (a), $userName!",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TourListPage(query: value.trim()),
                      ),
                    );
                  }
                },
                decoration: InputDecoration(
                  hintText: "Para onde você quer ir?",
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20),
                ),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle("Destaques do dia"),
                    _buildHorizontalList([
                      {"img": "lib/assets/images/coqueirinho.jpeg", "title": "Praia de Coqueirinho"},
                      {"img": "lib/assets/images/letreiro.jpeg", "title": "Pacote c/ desconto"},
                      {"img": "lib/assets/images/centrojoaopessoa.jpeg", "title": "Centro Histórico"},
                    ]),

                    _buildSectionTitle("Lugares populares perto de você"),
                    _buildHorizontalList([
                      {"img": "lib/assets/images/tambaba.jpeg", "title": "Praia de Tambaba"},
                      {"img": "lib/assets/images/piscinasnaturais.jpeg", "title": "Piscinas Naturais"},
                    ]),

                    _buildSectionTitle("Categorias"),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: const [
                          _CategoryIcon(icon: Icons.tour, label: "Passeios"),
                          _CategoryIcon(icon: Icons.hotel, label: "Hospedagem"),
                          _CategoryIcon(icon: Icons.restaurant, label: "Restaurantes"),
                          _CategoryIcon(icon: Icons.park, label: "Trilhas"),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Container(
              color: const Color(0xFF000080),
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.home, color: Colors.white),
                    label: const Text("Início"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0000CD),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AccountPage(userName: userName), 
                        ),
                      );
                    },
                    icon: const Icon(Icons.person, color: Colors.white),
                    label: const Text("Perfil"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0000CD),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }

  Widget _buildHorizontalList(List<Map<String, String>> items) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              image: DecorationImage(
                image: AssetImage(item["img"]!),
                fit: BoxFit.cover,
              ),
            ),
            child: Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
              child: Text(
                item["title"]!,
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _CategoryIcon extends StatelessWidget {
  final IconData icon;
  final String label;

  const _CategoryIcon({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: Colors.grey[200],
          child: Icon(icon, color: Colors.red),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

