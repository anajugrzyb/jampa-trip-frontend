import 'dart:io';
import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'addtour_page.dart';

class MyToursPage extends StatefulWidget {
  final String userName;
  const MyToursPage({super.key, required this.userName});

  @override
  State<MyToursPage> createState() => _MyToursPageState();
}

class _MyToursPageState extends State<MyToursPage> {
  List<Map<String, dynamic>> _tours = [];

  @override
  void initState() {
    super.initState();
    _carregarPasseios();
  }

  Future<void> _carregarPasseios() async {
    final db = DBHelper();
    final data = await db.getTours(empresa: widget.userName);
    setState(() {
      _tours = data;
    });
  }

  Widget _buildImage(String path) {
    final file = File(path);
    if (file.existsSync()) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          file,
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
      );
    } else {
      return Container(
        height: 180,
        decoration: BoxDecoration(
          color: Colors.blue[100],
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: const Icon(Icons.image_not_supported, size: 50, color: Colors.white),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        title: const Text(
          "Meus Passeios",
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      body: _tours.isEmpty
          ? const Center(
              child: Text(
                "Nenhum passeio cadastrado ainda.",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _tours.length,
              itemBuilder: (context, index) {
                final t = _tours[index];
                final imagens = (t['imagens'] as String?)?.split(',') ?? [];

                return Dismissible(
                  key: Key(t['id'].toString()),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white, size: 28),
                  ),
                  confirmDismiss: (direction) async {
                    return await showDialog<bool>(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text("Excluir passeio"),
                        content: const Text("Deseja realmente excluir este passeio?"),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text("Cancelar"),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text("Excluir", style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                  onDismissed: (direction) async {
                    await DBHelper().deleteTour(t['id']);
                    _carregarPasseios();

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text("Passeio '${t['nome']}' excluído com sucesso."),
                        backgroundColor: Colors.redAccent,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Card(
                    color: Colors.white,
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // imagens
                          if (imagens.isNotEmpty)
                            SizedBox(
                              height: 180,
                              child: PageView.builder(
                                itemCount: imagens.length,
                                controller: PageController(viewportFraction: 0.9),
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  child: _buildImage(imagens[index]),
                                ),
                              ),
                            ),
                          const SizedBox(height: 12),

                          // nome do passeio
                          Text(
                            t['nome'] ?? '',
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          const SizedBox(height: 8),

                          // informações
                          Row(
                            children: [
                              Icon(Icons.departure_board, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Saída: ${t['saida']}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.flag, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Chegada: ${t['chegada']}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              Icon(Icons.people, color: Colors.blue[700], size: 20),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  "Qtd. pessoas: ${t['qtd_pessoas'] ?? '-'}",
                                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 20),

                          Row(
                            children: [
                              const Icon(Icons.attach_money, color: Colors.green, size: 22),
                              const SizedBox(width: 6),
                              Text(
                                "Preço: R\$ ${t['preco']?.toStringAsFixed(2) ?? '0,00'}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 16),

                          // botão editar
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                final result = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => AddTourPage(
                                      tourToEdit: t,
                                      userName: widget.userName,
                                    ),
                                  ),
                                );
                                if (result == true) _carregarPasseios();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[400],
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 3,
                              ),
                              icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                              label: const Text(
                                "Editar",
                                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.blue[400],
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Cadastrar passeio",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTourPage(userName: widget.userName),
            ),
          );
          if (result == true) _carregarPasseios();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
