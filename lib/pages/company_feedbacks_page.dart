import 'package:flutter/material.dart';

import '../data/db_helper.dart';

class CompanyFeedbacksPage extends StatefulWidget {
  final String companyName;

  const CompanyFeedbacksPage({super.key, required this.companyName});

  @override
  State<CompanyFeedbacksPage> createState() => _CompanyFeedbacksPageState();
}

class _CompanyFeedbacksPageState extends State<CompanyFeedbacksPage> {
  final DBHelper _dbHelper = DBHelper();
  List<Map<String, dynamic>> _feedbacks = [];
  double _averageRating = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFeedbacks();
  }

  Future<void> _loadFeedbacks() async {
    final feedbacks = await _dbHelper.getFeedbacks(company: widget.companyName);
    final average =
        await _dbHelper.getAverageRatingForCompany(widget.companyName);

    if (!mounted) return;

    setState(() {
      _feedbacks = feedbacks;
      _averageRating = average;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    const Color azulEscuro = Color(0xFF000080);

    return Scaffold(
      backgroundColor: azulEscuro,
      appBar: AppBar(
        backgroundColor: azulEscuro,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Feedbacks recebidos',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Header(
              companyName: widget.companyName,
              averageRating: _averageRating,
              totalFeedbacks: _feedbacks.length,
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _feedbacks.isEmpty
                      ? const _EmptyState()
                      : RefreshIndicator(
                          onRefresh: _loadFeedbacks,
                          child: ListView.separated(
                            itemCount: _feedbacks.length,
                            separatorBuilder: (_, __) => const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final feedback = _feedbacks[index];
                              final rating = (feedback['rating'] as int?) ?? 0;
                              final comment =
                                  (feedback['comment'] as String?)?.trim() ?? '';
                              final tourName =
                                  (feedback['tour_nome'] as String?)?.trim() ?? '';
                              final createdAt = DateTime.tryParse(
                                      feedback['created_at']?.toString() ?? '') ??
                                  DateTime.now();

                              return _FeedbackCard(
                                rating: rating,
                                comment: comment,
                                tourName: tourName,
                                createdAt: createdAt,
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String companyName;
  final double averageRating;
  final int totalFeedbacks;

  const _Header({
    required this.companyName,
    required this.averageRating,
    required this.totalFeedbacks,
  });

  @override
  Widget build(BuildContext context) {
    const Color azulEscuro = Color(0xFF000080);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            companyName,
            style: const TextStyle(
              color: azulEscuro,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.star, color: Colors.amber, size: 22),
              const SizedBox(width: 6),
              Text(
                totalFeedbacks == 0
                    ? 'Sem avaliações'
                    : averageRating.toStringAsFixed(1),
                style: const TextStyle(
                  color: azulEscuro,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (totalFeedbacks > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '($totalFeedbacks comentários)',
                  style: const TextStyle(color: Colors.black54),
                ),
              ]
            ],
          ),
        ],
      ),
    );
  }
}

class _FeedbackCard extends StatelessWidget {
  final int rating;
  final String comment;
  final String tourName;
  final DateTime createdAt;

  const _FeedbackCard({
    required this.rating,
    required this.comment,
    required this.tourName,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: List.generate(
                5,
                (index) => Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: index < rating ? Colors.amber : Colors.grey[300],
                ),
              ),
            ),
            if (tourName.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                tourName,
                style: const TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 6),
            Text(
              comment.isEmpty ? 'Comentário não informado' : comment,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Recebido em ${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}',
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [
        Icon(Icons.chat_bubble_outline, color: Colors.white70, size: 48),
        SizedBox(height: 12),
        Text(
          'Nenhum feedback recebido ainda.',
          style: TextStyle(color: Colors.white70),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}