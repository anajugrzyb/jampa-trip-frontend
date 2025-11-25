import 'package:flutter/material.dart';
import 'package:jampa_trip/data/db_helper.dart';
import 'accountcompany_page.dart';
import 'login_page.dart';

class RegisterCompanyPage extends StatefulWidget {
  const RegisterCompanyPage({super.key});

  @override
  State<RegisterCompanyPage> createState() => _RegisterCompanyPageState();
}

class _RegisterCompanyPageState extends State<RegisterCompanyPage> {
  final companyNameController = TextEditingController();
  final cnpjController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  void _registerCompany() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("As senhas não coincidem")),
      );
      return;
    }

    final company = {
      'company_name': companyNameController.text.trim(),
      'cnpj': cnpjController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    await DBHelper().insertCompany(company);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Empresa cadastrada com sucesso!")),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) =>
            AccountCompanyPage(userName: companyNameController.text, userEmail: emailController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000080),
        title: const Text("Cadastro de Empresa", style: TextStyle(color: Colors.white, fontSize: 16) ),
        centerTitle: true,
        iconTheme: const IconThemeData(
          color: Colors.white, // ✅ Deixa o ícone de voltar branco
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Registre sua empresa",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  
                ),
              ),
              const SizedBox(height: 32),
              TextField(
                controller: companyNameController,
                decoration: InputDecoration(
                  labelText: "Nome da empresa",
                  labelStyle: const TextStyle(
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: cnpjController,
                decoration: InputDecoration(
                  labelText: "CNPJ",
                  labelStyle: const TextStyle(
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: "E-mail da empresa",
                  labelStyle: const TextStyle(
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration:  InputDecoration(
                  labelText: "Senha",
                  labelStyle: const TextStyle(
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: "Confirme a senha",
                  labelStyle: const TextStyle(
                          color: const Color.fromARGB(255, 90, 124, 225),
                          fontWeight: FontWeight.bold,
                        ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _registerCompany,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4169E1),
                    foregroundColor: Colors.white, 
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8), 
                    ),
                  ),
                  child: const Text(
                    "Cadastrar empresa",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Já possui uma conta? ",
                    style: TextStyle(color: Colors.white),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const LoginPage()),
                      );
                    },
                    child: const Text(
                      "Entrar",
                      style: TextStyle(
                        color: Color(0xFF4169E1),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

