import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../data/db_helper.dart';

class AddTourPage extends StatefulWidget {
  final Map<String, dynamic>? tourToEdit;

  const AddTourPage({super.key, this.tourToEdit});

  @override
  State<AddTourPage> createState() => _AddTourPageState();
}

class _AddTourPageState extends State<AddTourPage> {
  final _nomeController = TextEditingController();
  final _localController = TextEditingController();
  final _dataController = TextEditingController();
  final _saidaController = TextEditingController();
  final _chegadaController = TextEditingController();
  final _infoController = TextEditingController();
  int? _qtdPessoas;
  List<String> _imagens = [];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.tourToEdit != null) {
      final tour = widget.tourToEdit!;
      _nomeController.text = tour['nome'] ?? '';
      _localController.text = tour['local'] ?? '';
      _dataController.text = tour['datas'] ?? '';
      _saidaController.text = tour['saida'] ?? '';
      _chegadaController.text = tour['chegada'] ?? '';
      _infoController.text = tour['info'] ?? '';
      _qtdPessoas = int.tryParse(tour['qtd_pessoas'] ?? '0');
      _imagens = (tour['imagens'] as String?)?.split(',') ?? [];
    }
  }

  Future<void> _selecionarData() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2023),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _dataController.text = "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagens.add(image.path);
      });
    }
  }

  void _saveTour() async {
    final tour = {
      'nome': _nomeController.text.trim(),
      'local': _localController.text.trim(),
      'datas': _dataController.text.trim(),
      'saida': _saidaController.text.trim(),
      'chegada': _chegadaController.text.trim(),
      'info': _infoController.text.trim(),
      'qtd_pessoas': _qtdPessoas?.toString() ?? '0',
      'imagens': _imagens.join(','),
      'preco': 0.0,
    };

    final db = DBHelper();
    if (widget.tourToEdit != null) {
      await db.updateTour(widget.tourToEdit!['id'], tour);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passeio atualizado com sucesso!")),
      );
    } else {
      await db.insertTour(tour);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passeio cadastrado com sucesso!")),
      );
    }

    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: Text(
          widget.tourToEdit != null ? "Editar Passeio" : "Cadastrar Passeio",
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildStyledField("Digite o nome do passeio", _nomeController),
            _buildStyledField("Localização", _localController),
            GestureDetector(
              onTap: _selecionarData,
              child: AbsorbPointer(
                child: _buildStyledField("Datas disponíveis", _dataController),
              ),
            ),
            GestureDetector(
              onTap: () => _selecionarHora(_saidaController),
              child: AbsorbPointer(
                child: _buildStyledField("Horário de saída", _saidaController),
              ),
            ),
            GestureDetector(
              onTap: () => _selecionarHora(_chegadaController),
              child: AbsorbPointer(
                child: _buildStyledField("Horário de chegada", _chegadaController),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    dropdownColor: Colors.blue[800],
                    style: const TextStyle(color: Colors.white),
                    value: _qtdPessoas,
                    decoration: _inputDecoration("Qtd pessoas"),
                    items: List.generate(
                      20,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text("${i + 1}"),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _qtdPessoas = value;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Inserir imagens", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildStyledField("Informações adicionais", _infoController, maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTour,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[400],
                minimumSize: const Size(double.infinity, 55),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.tourToEdit != null ? "Atualizar" : "Adicionar",
                style: const TextStyle(fontSize: 18, color: Colors.white),
              ),
            ),
            const SizedBox(height: 20),
            const Center(
              child: Text(
                "Para continuar aceite os Termos",
                style: TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStyledField(String label, TextEditingController controller, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.white70),
      filled: true,
      fillColor: Colors.blue[800],
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }
}

