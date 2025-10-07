import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_time_picker_spinner/flutter_time_picker_spinner.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../data/db_helper.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_multi_formatter/flutter_multi_formatter.dart';

class AddTourPage extends StatefulWidget {
  final Map<String, dynamic>? tourToEdit;
  final String userName;

  const AddTourPage({
    super.key,
    this.tourToEdit,
    required this.userName,
  });

  @override
  State<AddTourPage> createState() => _AddTourPageState();
}

class _AddTourPageState extends State<AddTourPage> {
  final _nomeController = TextEditingController();
  final _saidaController = TextEditingController();
  final _chegadaController = TextEditingController();
  final _infoController = TextEditingController();
  final _precoController = TextEditingController();

  int? _qtdPessoas;
  List<DateTime> _datasSelecionadas = [];
  List<String> _imagens = [];
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();

    initializeDateFormatting('pt_BR', null).then((_) {
      setState(() {});
    });

    if (widget.tourToEdit != null) {
      final tour = widget.tourToEdit!;
      _nomeController.text = tour['nome'] ?? '';
      _saidaController.text = tour['saida'] ?? '';
      _chegadaController.text = tour['chegada'] ?? '';
      _infoController.text = tour['info'] ?? '';
      _qtdPessoas = int.tryParse(tour['qtd_pessoas'] ?? '0');
      _imagens = (tour['imagens'] as String?)?.split(',') ?? [];

      if (tour['datas'] != null && tour['datas'].toString().isNotEmpty) {
        _datasSelecionadas = tour['datas']
            .toString()
            .split(',')
            .map((s) => DateFormat('dd/MM/yyyy').parse(s.trim()))
            .toList();
      }

      if (tour['preco'] != null) {
        double preco = tour['preco'] is String
            ? double.tryParse(tour['preco']) ?? 0.0
            : (tour['preco'] as num).toDouble();
        _precoController.text = toCurrencyString(
          preco.toString(),
          leadingSymbol: 'R\$ ',
          useSymbolPadding: true,
          thousandSeparator: ThousandSeparator.Period,
          mantissaLength: 2,
        );
      }
    }
  }

  Future<void> _selecionarData() async {
    await showDialog(
      context: context,
      builder: (_) {
        DateTime focusedDay = DateTime.now();
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Selecione as datas disponíveis"),
              content: SizedBox(
                width: double.maxFinite,
                child: TableCalendar(
                  locale: 'pt_BR',
                  firstDay: DateTime(2023),
                  lastDay: DateTime(2100),
                  focusedDay: focusedDay,
                  selectedDayPredicate: (day) {
                    return _datasSelecionadas.any((d) => isSameDay(d, day));
                  },
                  onDaySelected: (selectedDay, _) {
                    setModalState(() {
                      if (_datasSelecionadas.any((d) => isSameDay(d, selectedDay))) {
                        _datasSelecionadas.removeWhere((d) => isSameDay(d, selectedDay));
                      } else {
                        _datasSelecionadas.add(selectedDay);
                      }
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    selectedDecoration: BoxDecoration(
                      color: Colors.lightBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Concluir"),
                ),
              ],
            );
          },
        );
      },
    );
    setState(() {});
  }

  Future<void> _selecionarHora(TextEditingController controller) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Selecione o horário"),
        content: SizedBox(
          height: 180,
          child: TimePickerSpinner(
            is24HourMode: true,
            normalTextStyle: const TextStyle(fontSize: 18, color: Colors.black54),
            highlightedTextStyle: const TextStyle(fontSize: 22, color: Colors.black),
            spacing: 50,
            itemHeight: 60,
            onTimeChange: (time) {
              controller.text =
                  '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
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
    String precoFormatado = _precoController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();

    final tour = {
      'nome': _nomeController.text.trim(),
      'datas': _datasSelecionadas
          .map((d) => DateFormat('dd/MM/yyyy').format(d))
          .join(', '), 
      'saida': _saidaController.text.trim(),
      'chegada': _chegadaController.text.trim(),
      'info': _infoController.text.trim(),
      'qtd_pessoas': _qtdPessoas?.toString() ?? '0',
      'imagens': _imagens.join(','),
      'preco': double.tryParse(precoFormatado) ?? 0.0,
      'empresa': widget.userName,
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

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: TextField(
                controller: _precoController,
                keyboardType: TextInputType.number,
                style: const TextStyle(color: Colors.white),
                inputFormatters: [
                  MoneyInputFormatter(
                    leadingSymbol: 'R\$ ',
                    useSymbolPadding: true,
                    thousandSeparator: ThousandSeparator.Period,
                    mantissaLength: 2,
                  ),
                ],
                decoration: _inputDecoration("Preço (R\$)"),
              ),
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
                  _datasSelecionadas.isEmpty
                      ? "Selecione as datas disponíveis"
                      : _datasSelecionadas
                          .map((d) => DateFormat('dd/MM/yyyy').format(d))
                          .join(', '),
                  style: const TextStyle(color: Colors.white),
                ),
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
                    padding: const EdgeInsets.symmetric(
                        vertical: 18, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text("Inserir imagens",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            _buildStyledField("Informações adicionais", _infoController,
                maxLines: 4),
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

  Widget _buildStyledField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        keyboardType: keyboardType,
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
