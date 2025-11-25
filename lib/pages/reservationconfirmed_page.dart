import 'package:flutter/material.dart';
import '../data/db_helper.dart';
import 'myreservation_page.dart';

class ReservationConfirmedPage extends StatelessWidget {
  final Map<String, dynamic> reserva;

  const ReservationConfirmedPage({
    super.key,
    required this.reserva,
  });

  Future<void> _salvarReserva() async {
    final db = DBHelper();
    final reservaComStatus = {
      ...reserva,
      'status': reserva['status'] ?? 'pendente',
    };

    await db.insertReserva(reservaComStatus);
  }

  @override
  Widget build(BuildContext context) {
    _salvarReserva(); 

    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text(
          "Confirmação de Reserva",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Card(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 6,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_circle_outline,
                    color: Colors.greenAccent,
                    size: 100,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    "Reserva Confirmada!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF001E6C),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Seu pagamento foi aprovado e sua reserva foi realizada com sucesso!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MyReservationsPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.list, color: Colors.white),
                    label: const Text(
                      "Ver Minhas Reservas",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      padding: const EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 4,
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
