import 'package:flutter/material.dart';
import 'package:jampa_trip/data/db_helper.dart';

class InformationCompanyPage extends StatefulWidget {
  final String email;

  const InformationCompanyPage({super.key, required this.email});

  @override
  State<InformationCompanyPage> createState() => _InformationCompanyPageState();
}

class _InformationCompanyPageState extends State<InformationCompanyPage> {
  final _formKey = GlobalKey<FormState>();
  final companyNameController = TextEditingController();
  final cnpjController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final db = DBHelper();
  Map<String, dynamic>? _company;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final dbClient = await db.db;
    final result = await dbClient.query(
      'companies',
      where: 'email = ?',
      whereArgs: [widget.email],
    );

    if (result.isNotEmpty) {
      setState(() {
        _company = result.first;
        companyNameController.text = _company!['company_name'] ?? '';
        cnpjController.text = _company!['cnpj'] ?? '';
        emailController.text = _company!['email'] ?? '';
        passwordController.text = _company!['password'] ?? '';
      });
    }
  }

  Future<void> _updateCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final updatedCompany = {
      'company_name': companyNameController.text.trim(),
      'cnpj': cnpjController.text.trim(),
      'email': emailController.text.trim(),
      'password': passwordController.text.trim(),
    };

    final dbClient = await db.db;
    await dbClient.update(
      'companies',
      updatedCompany,
      where: 'id = ?',
      whereArgs: [_company!['id']],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Informações da empresa atualizadas com sucesso!',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscure = false,
    TextInputType inputType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        obscureText: obscure,
        keyboardType: inputType,
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF4169E1),
            fontWeight: FontWeight.bold,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        validator: (value) =>
            value!.isEmpty ? "Campo obrigatório: $label" : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text(
          "Informações da Empresa",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 26),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _company == null
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Card(
                color: Colors.white,
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Atualize as informações da empresa",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF00008B),
                          ),
                        ),
                        const SizedBox(height: 20),

                        _buildTextField(
                            label: "Nome da empresa",
                            controller: companyNameController),
                        _buildTextField(
                          label: "CNPJ",
                          controller: cnpjController,
                          inputType: TextInputType.number,
                        ),
                        _buildTextField(
                            label: "Email da empresa",
                            controller: emailController),
                        _buildTextField(
                          label: "Senha",
                          controller: passwordController,
                          obscure: true,
                        ),

                        const SizedBox(height: 30),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _updateCompany,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue[400],
                              padding:
                                  const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                            ),
                            icon: const Icon(Icons.save, color: Colors.white),
                            label: const Text(
                              "Salvar Alterações",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
