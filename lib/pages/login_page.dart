import 'package:flutter/material.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080), 
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              // Seja bem vindo
               const Text(
                "Seja bem vindo (a)!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Poppins',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Logo
              Image.asset(
                "lib/assets/images/planeta.png",
                 height: 180, 
                 width: 180,
              ),
              const SizedBox(height: 16),

              // Campo de email
              TextField(
                style: const TextStyle(fontFamily: 'Poppins', color: Color.fromARGB(255, 0, 0, 0)),
                decoration: InputDecoration(
                  labelText: "Digite seu email",
                  labelStyle: const TextStyle(fontFamily: 'Poppins', color: Color.fromARGB(255, 0, 0, 0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Campo de senha
              TextField(
                obscureText: true,
                style: const TextStyle(fontFamily: 'Poppins', color: Color.fromARGB(255, 0, 0, 0)),
                decoration: InputDecoration(
                  labelText: "Digite sua senha",
                  labelStyle: const TextStyle(fontFamily: 'Poppins', color: Color.fromARGB(255, 0, 0, 0)),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              const SizedBox(height: 16),

               // Esqueceu a senha
              TextButton(
                onPressed: () {
                  // ação para recuperar senha
                },
                child: const Text(
                  "Esqueceu sua senha?",
                  style: TextStyle(fontFamily: 'Poppins',color: Color(0xFF4169E1)),
                ),
              ),
              const SizedBox(height: 16),

              // Botão Login
              SizedBox(
                width: 400, // define a largura
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4169E1),
                    foregroundColor: const Color(0xFFFFFFFF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Login", style: TextStyle(fontFamily: 'Poppins', fontSize: 16)),
                ),
              ),

              const SizedBox(height: 16),

              // Link para cadastro
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Não possui uma conta? ",
                      style: TextStyle(fontFamily: 'Poppins', color: Colors.white)),
                  GestureDetector(
                    onTap: () {
                      // ação para cadastro
                    },
                    child: const Text(
                      "Cadastre-se",
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        color: Color(0xFF4169E1),
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

