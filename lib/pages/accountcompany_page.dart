import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../data/db_helper.dart';
import 'informationcompany_page.dart';
import 'mytours_page.dart';
import 'login_page.dart';

class AccountCompanyPage extends StatefulWidget {
  final String userName;
  final String userEmail; 

  const AccountCompanyPage({
    super.key,
    required this.userName,
    required this.userEmail,
  });

  @override
  State<AccountCompanyPage> createState() => _AccountCompanyPageState();
}

class _AccountCompanyPageState extends State<AccountCompanyPage> {
  File? _selectedImage;
  final db = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadCompanyImage();
  }

  Future<void> _loadCompanyImage() async {
    final logoPath = await db.getCompanyLogo(widget.userEmail);
    if (logoPath != null && File(logoPath).existsSync()) {
      setState(() {
        _selectedImage = File(logoPath);
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
      await db.updateCompanyLogo(widget.userEmail, image.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),

            Center(
              child: Stack(
                alignment: Alignment.bottomRight,
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundImage: _selectedImage != null
                        ? FileImage(_selectedImage!)
                        : const AssetImage("assets/profile.jpg")
                            as ImageProvider,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 4,
                    child: InkWell(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.blue, width: 2),
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.blue,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),
            Text(
              widget.userName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              "Informações da empresa",
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 20),

            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF0018A8),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ListView(
                  children: [
                    _buildMenuItem(
                      icon: Icons.person,
                      title: "Login",
                      subtitle: "Informações de login",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InformationCompanyPage(
                              email: widget.userEmail, 
                            ),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.notification_add,
                      title: "Passeios",
                      subtitle: "Meus passeios, cadastrar",
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MyToursPage(userName: widget.userName),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.bookmark,
                      title: "Reservas",
                      subtitle: "Minhas reservas, cancelamentos",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.history,
                      title: "Histórico",
                      subtitle: "Meus passeios",
                      onTap: () {},
                    ),
                    _buildMenuItem(
                      icon: Icons.feedback,
                      title: "Feedback",
                      subtitle: "Meus comentários",
                      onTap: () {},
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const LoginPage()),
                          (Route<dynamic> route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout),
                      label: const Text("Sair"),
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

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue.shade900),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing:
            const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.blue),
        onTap: onTap,
      ),
    );
  }
}
