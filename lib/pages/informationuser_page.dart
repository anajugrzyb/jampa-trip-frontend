import 'package:flutter/material.dart';
import 'package:jampa_trip/data/db_helper.dart';

class InformationUserPage extends StatefulWidget {
  final String email; 

  const InformationUserPage({super.key, required this.email});

  @override
  State<InformationUserPage> createState() => _InformationUserPageState();
}

class _InformationUserPageState extends State<InformationUserPage> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final db = DBHelper();
  Map<String, dynamic>? _user;

  @override
  void initState() {
    super.initState();
    _loadUser();
  }

  Future<void> _loadUser() async {
    final dbClient = await db.db;
    final result = await dbClient.query(
      'users',
      where: 'email = ?',
      whereArgs: [widget.email],
    );

    if (result.isNotEmpty) {
      setState(() {
        _user = result.first;
        nameController.text = _user!['name'] ?? '';
        emailController.text = _user!['email'] ?? '';
        passwordController.text = _user!['password'] ?? '';
      });
    }
  }

  Future<void> _updateUser() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedUser = {
      'name': nameController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    final dbClient = await db.db;
    await dbClient.update(
      'users',
      updatedUser,
      where: 'id = ?',
      whereArgs: [_user!['id']],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Informações atualizadas com sucesso!',
          style: TextStyle(
            fontFamily: 'Poppins',
            color: Colors.white,
          ),
        ),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      appBar: AppBar(
        title: const Text("Informações do Usuário", 
        style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
        backgroundColor: const Color(0xFF4169E1),
        elevation: 0,
      ),
      body: _user == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const Text(
                      "Atualize suas informações",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 24),

                    TextFormField(
                      controller: nameController,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Nome completo",
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins', 
                          color: Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Digite seu nome" : null,
                    ),

                    const SizedBox(height: 16),

                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Email",
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins',
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Digite seu email" : null,
                    ),
                    const SizedBox(height: 16),

                    TextFormField(
                      controller: passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.black),
                      decoration: InputDecoration(
                        labelText: "Senha",
                        labelStyle: const TextStyle(
                          fontFamily: 'Poppins', 
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      validator: (value) =>
                          value!.isEmpty ? "Digite sua senha" : null,
                    ),
                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _updateUser,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4169E1),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          "Salvar Alterações",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
