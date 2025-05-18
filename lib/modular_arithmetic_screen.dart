import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ModularArithmeticScreen extends StatefulWidget {
  const ModularArithmeticScreen({super.key});

  @override
  State<ModularArithmeticScreen> createState() => _ModularArithmeticScreenState();
}

class _ModularArithmeticScreenState extends State<ModularArithmeticScreen> {
  final TextEditingController _aController = TextEditingController();
  final TextEditingController _bController = TextEditingController();
  final TextEditingController _mController = TextEditingController();
  String result = '';
  List<Map<String, String>> steps = [];

  void calculate(String op) {
    final int? a = int.tryParse(_aController.text);
    final int? b = int.tryParse(_bController.text);
    final int? m = int.tryParse(_mController.text);
    if (a == null || b == null || m == null || m <= 0) return;
    steps.clear();

    int res;
    switch (op) {
      case 'add':
        res = (a + b) % m;
        steps.add({'operation': '($a + $b) mod $m', 'result': '$res'});
        break;
      case 'sub':
        res = (a - b) % m;
        if (res < 0) res += m;
        steps.add({'operation': '($a - $b) mod $m', 'result': '$res'});
        break;
      case 'mul':
        res = (a * b) % m;
        steps.add({'operation': '($a \u00D7 $b) mod $m', 'result': '$res'});
        break;
      case 'exp':
        res = a;
        int exponent = b;
        steps.add({'operation': 'Start: $a', 'result': '$res'});
        for (int i = 1; i <= exponent; i++) {
          res = (res * a) % m;
          steps.add({'operation': 'Step $i: ($res) mod $m', 'result': '$res'});
        }
        break;
      case 'inv':
        res = -1;
        for (int x = 1; x < m; x++) {
          if ((a * x) % m == 1) {
            res = x;
            break;
          }
        }
        steps.add({'operation': 'Inverse of $a mod $m', 'result': res > 0 ? '$res' : 'None'});
        break;
      default:
        return;
    }

    setState(() {
      result = res >= 0 ? '$res' : 'None';
    });
  }

  @override
  void dispose() {
    _aController.dispose();
    _bController.dispose();
    _mController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Modular Arithmetic Visualizer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _aController.clear();
              _bController.clear();
              _mController.clear();
              setState(() {
                result = '';
                steps.clear();
              });
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _aController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Value a',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Value b / Exponent',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _mController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Modulus m',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: [
                ElevatedButton(
                  onPressed: () => calculate('add'),
                  child: const Text('Add mod'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('sub'),
                  child: const Text('Sub mod'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('mul'),
                  child: const Text('Mul mod'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('exp'),
                  child: const Text('Exp mod'),
                ),
                ElevatedButton(
                  onPressed: () => calculate('inv'),
                  child: const Text('Inv mod'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (result.isNotEmpty) ...[
              Text('Result:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(result, style: const TextStyle(fontSize: 28)),
            ],
            const SizedBox(height: 24),
            if (steps.isNotEmpty) ...[
              Text('Steps:', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Column(
                children: steps.map((step) {
                  return ListTile(
                    title: Text(step['operation']!),
                    trailing: Text(step['result']!, style: const TextStyle(fontWeight: FontWeight.bold)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}