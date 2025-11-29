import 'package:flutter/material.dart';

import '../data/db_helper.dart';

class MyFeedbacksPage extends StatefulWidget {
  final String userEmail;

  const MyFeedbacksPage({super.key, required this.userEmail});

  @override
  State<MyFeedbacksPage> createState() => _MyFeedbacksPageState();
}

class _MyFeedbacksPageState extends State<MyFeedbacksPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _feedbacks = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    setState(() => _isLoading = true);
    final data = await _dbHelper.getFeedbacksByUser(widget.userEmail);

    if (mounted) {
      setState(() {
        _feedbacks = data;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteFeedback(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir feedback'),
        content:
            const Text('Deseja realmente excluir este comentário? Esta ação não pode ser desfeita.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    await _dbHelper.deleteFeedback(id);
    await _loadFeedbacks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback excluído com sucesso.')),
      );
    }
  }

  Future<void> _showEditDialog(Map<String, dynamic> feedback) async {
    final controller = TextEditingController(text: feedback['comment'] as String? ?? '');
    int rating = feedback['rating'] as int? ?? 0;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text('Editar feedback'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Avaliação'),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: List.generate(5, (index) {
                  final isSelected = index < rating;
                  return IconButton(
                    visualDensity: VisualDensity.compact,
                    icon: Icon(
                      Icons.star_rounded,
                      color: isSelected ? Colors.amber : Colors.grey[300],
                    ),
                    onPressed: () => setStateDialog(() => rating = index + 1),
                  );
                }),
              ),
              const SizedBox(height: 12),
              const Text('Comentário'),
              const SizedBox(height: 8),
              TextField(
                controller: controller,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Atualize seu comentário',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                if (rating == 0 || controller.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Informe uma nota e um comentário.')),
                  );
                  return;
                }
                Navigator.of(context).pop(true);
              },
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );

    if (result != true) return;

    await _dbHelper.updateFeedback(
      id: feedback['id'] as int,
      rating: rating,
      comment: controller.text.trim(),
    );
    await _loadFeedbacks();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Feedback atualizado com sucesso.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color azulEscuro = Color(0xFF00008B);
    final Color azulClaro = Colors.blue[400]!;

    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Meus feedbacks',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadFeedbacks,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Feedbacks enviados',
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (_feedbacks.isEmpty)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Text(
                          'Você ainda não enviou nenhum feedback.',
                          style: TextStyle(color: Colors.black54),
                        ),
                      )
                    else
                      ListView.separated(
                        itemCount: _feedbacks.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final item = _feedbacks[index];
                          final createdAt = DateTime.tryParse(
                                  item['created_at']?.toString() ?? '') ??
                              DateTime.now();

                          return ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if ((item['company'] as String?)?.isNotEmpty == true)
                                  Text(
                                    item['company'] as String,
                                    style: const TextStyle(
                                      color: Colors.black87,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                if ((item['tour_nome'] as String?)?.isNotEmpty == true)
                                  Text(
                                    item['tour_nome'] as String,
                                    style: const TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  children: List.generate(
                                    5,
                                    (i) => Icon(
                                      Icons.star_rounded,
                                      size: 20,
                                      color: i < (item['rating'] as int? ?? 0)
                                          ? Colors.amber
                                          : Colors.grey[300],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item['comment'] as String? ?? '',
                                  style: const TextStyle(
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Enviado em ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
                                  style: const TextStyle(color: Colors.black54, fontSize: 12),
                                ),
                              ],
                            ),
                            trailing: Wrap(
                              spacing: 8,
                              children: [
                                IconButton(
                                  icon: Icon(Icons.edit_outlined, color: azulClaro),
                                  onPressed: () => _showEditDialog(item),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                  onPressed: () {
                                    final id = item['id'] as int?;
                                    if (id != null) {
                                      _deleteFeedback(id);
                                    }
                                  },
                                ),
                              ],
                            ),
                          );
                        },
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
}