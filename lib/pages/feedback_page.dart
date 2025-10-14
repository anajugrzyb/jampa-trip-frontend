import 'package:flutter/material.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  int _rating = 0;
  final TextEditingController _controller = TextEditingController();

  void _submitFeedback() {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Por favor, selecione uma quantidade de estrelas."),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Feedback enviado com sucesso! Obrigado pelo retorno."),
      ),
    );

    setState(() {
      _rating = 0;
      _controller.clear();
    });
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
                        onPressed: _submitFeedback,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: azulClaro,
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: const Icon(Icons.send_rounded, color: Colors.white),
                        label: const Text(
                          "Enviar comentário",
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

            const SizedBox(height: 20),
           
          ],
        ),
      ),
    );
  }


  }

