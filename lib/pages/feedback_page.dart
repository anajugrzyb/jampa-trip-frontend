import 'package:flutter/material.dart';

import '../data/db_helper.dart';

class FeedbackPage extends StatefulWidget {
  final String? companyName;
  final String? tourName;

  const FeedbackPage({super.key, this.companyName, this.tourName});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  bool _isSubmitting = false;
  bool _isLoading = true;
  double _averageRating = 0;
  final DBHelper _dbHelper = DBHelper();
  final TextEditingController _controller = TextEditingController();
  List<Map<String, dynamic>> _feedbacks = [];

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    final feedbacks = await _dbHelper.getFeedbacks(company: widget.companyName);
    final average = widget.companyName != null && widget.companyName!.isNotEmpty
        ? await _dbHelper.getAverageRatingForCompany(widget.companyName!)
        : 0;
    if (mounted) {
      setState(() {
        _feedbacks = feedbacks;
        _isLoading = false;
        _averageRating = average.toDouble();

      });
    }
  }

  Future<void> _submitFeedback() async {
    if (_isSubmitting) return;

    final comment = _controller.text.trim();

    if (widget.companyName == null || widget.companyName!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              "Selecione um passeio ou empresa para enviar o feedback."),
        ),
      );
      return;
    }

    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione uma quantidade de estrelas."),
        ),
      );
      return;
    }

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, escreva um comentário antes de enviar."),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    await _dbHelper.insertFeedback(
      rating: _rating,
      comment: comment,
      company: widget.companyName!,
      tourName: widget.tourName,
    );
    await _loadFeedbacks();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Feedback enviado com sucesso! Obrigado pelo retorno."),
      ),
    );

    setState(() {
      _rating = 0;
      _controller.clear();
      _isSubmitting = false;
    });
  }

  Future<void> _deleteFeedback(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir feedback'),
        content: const Text('Deseja realmente excluir este comentário?'),
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
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
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Feedback",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            if (widget.companyName != null)
              Column(
                children: [
                  Text(
                    "Feedback para ${widget.companyName}",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.tourName != null)
                    Text(
                      widget.tourName!,
                      style: TextStyle(
                        color: Colors.blue[100],
                        fontSize: 14,
                      ),
                    ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.amber[400]),
                      const SizedBox(width: 6),
                      Text(
                        _feedbacks.isEmpty
                            ? "Sem avaliações"
                            : _averageRating.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      if (_feedbacks.isNotEmpty) ...[
                        const SizedBox(width: 6),
                        Text(
                          "(${_feedbacks.length} comentários)",
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ]
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            Text(
              "Nos conte sua experiência!",
              style: TextStyle(
                color: Colors.blue[100],
                fontSize: 17,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 25),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    Icons.star_rounded,
                    size: 36,
                    color: index < _rating ? Colors.amber : Colors.white24,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),
            Text(
              _rating == 0 ? "Avalie de 1 a 5 estrelas" : "$_rating/5 Estrelas",
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),

            const SizedBox(height: 30),


            Card(
              color: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Seu comentário",
                      style: TextStyle(
                        color: azulEscuro,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _controller,
                      maxLines: 4,
                      style: const TextStyle(color: Colors.black87),
                      decoration: InputDecoration(
                        hintText: "Escreva aqui o que achou do passeio...",
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        filled: true,
                        fillColor: Colors.grey[100],
                        border: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: azulClaro, width: 1.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),


                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSubmitting ? null : _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulClaro,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        label: Text(
                          _isSubmitting ? "Enviando..." : "Enviar comentário",
                          style: const TextStyle(
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

            const SizedBox(height: 20),

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
                      "Feedbacks enviados",
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
                          "Você ainda não enviou nenhum feedback.",
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
                            leading: Row(
                              mainAxisSize: MainAxisSize.min,
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
                            title: Text(
                              item['comment'] as String? ?? '',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            subtitle: Text(
                              "Enviado em ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}",
                              style: const TextStyle(color: Colors.black54),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                              onPressed: () {
                                final id = item['id'] as int?;
                                if (id != null) {
                                  _deleteFeedback(id);
                                }
                              },
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

