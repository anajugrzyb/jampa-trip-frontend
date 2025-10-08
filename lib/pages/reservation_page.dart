import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
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

  String? _dataSelecionada;
  List<String> _datasDisponiveis = [];
  Set<String> _datasLotadas = {};

  @override
  void initState() {
    super.initState();
    _carregarDatas();
  }

  Future<void> _carregarDatas() async {
    final db = DBHelper();
    final qtdMaxima = int.tryParse(widget.tour['qtd_pessoas'].toString()) ?? 1;

    final datas = widget.tour['datas']
        .toString()
        .split(',')
        .map((s) => s.trim())
        .toList();

    Set<String> datasLotadas = {};

    for (String data in datas) {
      final total = await db.getTotalReservasPorData(widget.tour['id'], data);
      if (total >= qtdMaxima) {
        datasLotadas.add(data);
      }
    }

    setState(() {
      _datasDisponiveis = datas;
      _datasLotadas = datasLotadas;
    });
  }

  Future<void> _selecionarData() async {
    await initializeDateFormatting('pt_BR', null);
    DateTime focusedDay = DateTime.now();

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          backgroundColor: const Color(0xFF001E6C),
          title: const Text(
            "Selecione a data do passeio",
            style: TextStyle(color: Colors.white),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: TableCalendar(
              locale: 'pt_BR',
              firstDay: DateTime(2023),
              lastDay: DateTime(2100),
              focusedDay: focusedDay,
              availableCalendarFormats: const {CalendarFormat.month: 'Mês'},
              headerStyle: const HeaderStyle(
                titleCentered: true,
                formatButtonVisible: false,
                titleTextStyle: TextStyle(color: Colors.white),
                leftChevronIcon:
                    Icon(Icons.chevron_left, color: Colors.white),
                rightChevronIcon:
                    Icon(Icons.chevron_right, color: Colors.white),
              ),
              calendarStyle: const CalendarStyle(
                todayDecoration: BoxDecoration(
                    color: Colors.lightBlue, shape: BoxShape.circle),
                selectedDecoration:
                    BoxDecoration(color: Colors.green, shape: BoxShape.circle),
                defaultTextStyle: TextStyle(color: Colors.white),
                weekendTextStyle: TextStyle(color: Colors.white70),
                outsideTextStyle: TextStyle(color: Colors.white38),
              ),
              selectedDayPredicate: (day) {
                if (_dataSelecionada == null) return false;
                final dataFormatada = DateFormat('dd/MM/yyyy').format(day);
                return dataFormatada == _dataSelecionada;
              },  
              enabledDayPredicate: (day) {
                final dataStr = DateFormat('dd/MM/yyyy').format(day);
                return _datasDisponiveis.contains(dataStr) &&
                    !_datasLotadas.contains(dataStr);
              },
              onDaySelected: (selectedDay, _) {
                final dataFormatada =
                    DateFormat('dd/MM/yyyy').format(selectedDay);
                if (_datasLotadas.contains(dataFormatada)) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Esta data está lotada."),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
                setState(() {
                  _dataSelecionada = dataFormatada;
                });
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text("Fechar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _confirmarReserva() async {
    if (_formKey.currentState!.validate()) {
      if (_dataSelecionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Selecione uma data antes de continuar."),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      _formKey.currentState!.save();
      final db = DBHelper();
      final qtdMaxima = int.tryParse(widget.tour['qtd_pessoas'].toString()) ?? 1;
      final totalExistente =
          await db.getTotalReservasPorData(widget.tour['id'], _dataSelecionada!);

      if (totalExistente + _qtdReservada > qtdMaxima) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Número de vagas insuficiente nesta data."),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final reserva = {
        "tour_id": widget.tour['id'],
        "nome": _nome,
        "telefone": _telefone,
        "endereco": _endereco,
        "qtd_pessoas": _qtdReservada,
        "data_reserva": _dataSelecionada,
        "observacoes": _observacoes,
      };

      await db.insertReserva(reserva);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Reserva salva com sucesso!"),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushNamed(context, '/payment', arguments: reserva);
    }
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

  Widget _buildStyledField({
    required String label,
    required FormFieldSetter<String> onSaved,
    String? Function(String?)? validator,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextFormField(
        style: const TextStyle(color: Colors.white),
        decoration: _inputDecoration(label),
        keyboardType: keyboardType,
        maxLines: maxLines,
        validator: validator,
        onSaved: onSaved,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int qtdMaxima =
        int.tryParse(widget.tour['qtd_pessoas'].toString()) ?? 1;

    return Scaffold(
      backgroundColor: const Color(0xFF00008B),
      appBar: AppBar(
        title: const Text(
          "Reservar Passeio",
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: const Color(0xFF00008B),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildStyledField(
                label: "Nome completo",
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe seu nome" : null,
                onSaved: (v) => _nome = v ?? "",
              ),
              _buildStyledField(
                label: "Número de telefone",
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe seu telefone" : null,
                onSaved: (v) => _telefone = v ?? "",
              ),

              GestureDetector(
                onTap: _selecionarData,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[800],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _dataSelecionada == null
                        ? "Selecione a data do passeio"
                        : "Data selecionada: $_dataSelecionada",
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ),

              _buildStyledField(
                label: "Endereço (local de hospedagem)",
                validator: (v) =>
                    v == null || v.isEmpty ? "Informe o endereço" : null,
                onSaved: (v) => _endereco = v ?? "",
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Quantidade de pessoas (máx: $qtdMaxima)",
                      style:
                          const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.remove_circle, color: Colors.redAccent),
                    onPressed: () {
                      if (_qtdReservada > 1) setState(() => _qtdReservada--);
                    },
                  ),
                  Text(
                    "$_qtdReservada",
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.greenAccent),
                    onPressed: () {
                      if (_qtdReservada < qtdMaxima) {
                        setState(() => _qtdReservada++);
                      }
                    },
                  ),
                ],
              ),
              _buildStyledField(
                label: "Observações adicionais",
                maxLines: 3,
                onSaved: (v) => _observacoes = v ?? "",
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _confirmarReserva,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[400],
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Confirmar e Ir para Pagamento",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
