import 'package:flutter/material.dart';
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
  final _saidaController = TextEditingController();
  final _chegadaController = TextEditingController();
  final _precoController = TextEditingController();
  List<String> _imagens = [];

  @override
  void initState() {
    super.initState();
    if (widget.tourToEdit != null) {
      final tour = widget.tourToEdit!;
      _nomeController.text = tour['nome'];
      _saidaController.text = tour['saida'];
      _chegadaController.text = tour['chegada'];
      _precoController.text = tour['preco']?.toString() ?? '';
      _imagens = (tour['imagens'] as String?)?.split(',') ?? [];
    }
  }

  void _saveTour() async {
    final tour = {
      'nome': _nomeController.text.trim(),
      'saida': _saidaController.text.trim(),
      'chegada': _chegadaController.text.trim(),
      'preco': _precoController.text.trim(),
      'imagens': _imagens.join(','),
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
      appBar: AppBar(
        title: Text(widget.tourToEdit != null ? "Editar Passeio" : "Cadastrar Passeio"),
        backgroundColor: Colors.blue[800],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(labelText: "Nome do passeio"),
            ),
            TextField(
              controller: _saidaController,
              decoration: const InputDecoration(labelText: "Saída"),
            ),
            TextField(
              controller: _chegadaController,
              decoration: const InputDecoration(labelText: "Chegada"),
            ),
            TextField(
              controller: _precoController,
              decoration: const InputDecoration(labelText: "Preço"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveTour,
              child: Text(widget.tourToEdit != null ? "Atualizar passeio" : "Cadastrar passeio"),
            ),
          ],
        ),
      ),
    );
  }
}
