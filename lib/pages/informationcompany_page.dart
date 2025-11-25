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
  final descricaoController = TextEditingController();

  final db = DBHelper();
  Map<String, dynamic>? _company;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadCompany();
  }

  Future<void> _loadCompany() async {
    final company = await db.getCompanyByEmail(widget.email);

    setState(() {
      if (company != null) {
        _company = company;
        companyNameController.text = company['company_name'] ?? '';
        cnpjController.text = company['cnpj'] ?? '';
        emailController.text = company['email'] ?? '';
        passwordController.text = company['password'] ?? '';
        descricaoController.text = company['descricao'] ?? '';
      }
      _loading = false;
    });
  }

  Future<void> _updateCompany() async {
    if (!_formKey.currentState!.validate()) return;

    final dbClient = await db.db;
    await dbClient.update(
      'companies',
      {
        'company_name': companyNameController.text.trim(),
        'cnpj': cnpjController.text.trim(),
        'email': emailController.text.trim(),
        'password': passwordController.text.trim(),
        'descricao': descricaoController.text.trim(),
      },
      where: 'email = ?',
      whereArgs: [widget.email],
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Informações da empresa atualizadas com sucesso!'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF000080),
      appBar: AppBar(
        backgroundColor: const Color(0xFF000080),
        title: const Text("Informações da Empresa", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : _company == null
              ? const Center(
                  child: Text(
                    "Nenhuma empresa encontrada para este e-mail.",
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          "Edite suas informações",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 32),
                        _buildTextField(companyNameController, "Nome da empresa"),
                        const SizedBox(height: 16),
                        _buildTextField(cnpjController, "CNPJ", keyboardType: TextInputType.number),
                        const SizedBox(height: 16),
                        _buildTextField(emailController, "E-mail da empresa", keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 16),
                        _buildTextField(passwordController, "Senha", obscureText: true),
                        const SizedBox(height: 16),
                        _buildTextField(descricaoController, "Descrição", maxLines: 4),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _updateCompany,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF4169E1),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text(
                              "Salvar alterações",
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {bool obscureText = false, int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: (value) => value == null || value.isEmpty ? 'Preencha este campo' : null,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(
          color: Color.fromARGB(255, 90, 124, 225),
          fontWeight: FontWeight.bold,
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
      ),
    );
  }
}
