import 'package:flutter/material.dart';
import '../data/db_helper.dart'; 

class ReservationPage extends StatefulWidget {
  final Map<String, dynamic> tour;

  const ReservationPage({super.key, required this.tour});

  @override
  State<ReservationPage> createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  final _formKey = GlobalKey<FormState>();

  String _nome = "";
  String _telefone = "";
  String _endereco = "";
  String _observacoes = "";
  int _qtdReservada = 1;

  @override
  Widget build(BuildContext context) {
    final int qtdMaxima = int.tryParse(widget.tour['qtd_pessoas'].toString()) ?? 1;

    return Scaffold(
      backgroundColor: Colors.blue[50],
      appBar: AppBar(
        title: const Text(
          "Reservar Passeio",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.blue[800],
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 3,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Nome completo",
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Informe seu nome" : null,
                    onSaved: (value) => _nome = value ?? "",
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Número de telefone",
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.phone,
                    validator: (value) =>
                        value == null || value.isEmpty ? "Informe seu telefone" : null,
                    onSaved: (value) => _telefone = value ?? "",
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Endereço (local de hospedagem)",
                      prefixIcon: Icon(Icons.location_on),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        value == null || value.isEmpty ? "Informe o endereço" : null,
                    onSaved: (value) => _endereco = value ?? "",
                  ),
                  const SizedBox(height: 16),

                  Row(
                    children: [
                      const Icon(Icons.people, color: Colors.blue),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          "Quantidade de pessoas (máximo: $qtdMaxima)",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_qtdReservada > 1) {
                                setState(() => _qtdReservada--);
                              }
                            },
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                          ),
                          Text(
                            "$_qtdReservada",
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          IconButton(
                            onPressed: () {
                              if (_qtdReservada < qtdMaxima) {
                                setState(() => _qtdReservada++);
                              }
                            },
                            icon: const Icon(Icons.add_circle, color: Colors.green),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    decoration: const InputDecoration(
                      labelText: "Observações adicionais",
                      prefixIcon: Icon(Icons.notes),
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _observacoes = value ?? "",
                  ),
                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();

                          final reserva = {
                            "tour_id": widget.tour['id'],
                            "nome": _nome,
                            "telefone": _telefone,
                            "endereco": _endereco,
                            "qtd_pessoas": _qtdReservada,
                            "observacoes": _observacoes,
                          };

                          await DBHelper().insertReserva(reserva);

                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Reserva salva com sucesso!"),
                              backgroundColor: Colors.green,
                            ),
                          );

                          Navigator.pushNamed(context, '/payment', arguments: reserva);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                      icon: const Icon(Icons.check_circle, size: 22),
                      label: const Text(
                        "Confirmar e Ir para Pagamento",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
