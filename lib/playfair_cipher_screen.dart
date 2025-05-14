import 'package:flutter/material.dart';

class PlayfairCipherScreen extends StatefulWidget {
  const PlayfairCipherScreen({super.key});

  @override
  State<PlayfairCipherScreen> createState() => _PlayfairCipherScreenState();
}

class _PlayfairCipherScreenState extends State<PlayfairCipherScreen> {
  final TextEditingController inputController = TextEditingController();
  final TextEditingController keyController = TextEditingController();

  String result = '';
  bool isEncrypt = true;
  bool showSteps = false;

  List<List<String>> matrix = List.generate(5, (_) => List.filled(5, ''));
  List<Map<String, String>> steps = [];

  void processText() {
    final inputText = inputController.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').replaceAll('J', 'I');
    final key = keyController.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '').replaceAll('J', 'I');

    if (inputText.isEmpty || key.isEmpty) {
      setState(() {
        result = '';
        steps.clear();
        matrix = List.generate(5, (_) => List.filled(5, ''));
      });
      return;
    }

    final fullMatrix = _generateMatrix(key);
    matrix = fullMatrix;

    final cleanedInput = _prepareInput(inputText);
    steps.clear();
    final buffer = StringBuffer();

    for (var pair in cleanedInput) {
      final res = _processPair(pair[0], pair[1], fullMatrix);
      buffer.write(res['output']);
      steps.add({
        isEncrypt ? 'Text' : 'Cipher': '${pair[0]}${pair[1]}',
        'Key': key,
        'Rule': res['rule']!,
        'Result': res['output']!,
      });
    }

    setState(() {
      result = buffer.toString();
    });
  }

  List<List<String>> _prepareInput(String text) {
    final chars = text.split('');
    final result = <List<String>>[];

    int i = 0;
    while (i < chars.length) {
      final first = chars[i];
      String second;

      if (i + 1 >= chars.length) {
        second = 'X';
      } else {
        second = chars[i + 1];
        if (first == second) {
          second = 'X';
        } else {
          i++;
        }
      }

      result.add([first, second]);
      i++;
    }

    return result;
  }

  List<List<String>> _generateMatrix(String key) {
    final seen = <String>{};
    final letters = <String>[];

    for (var c in key.split('')) {
      if (!seen.contains(c)) {
        seen.add(c);
        letters.add(c);
      }
    }

    for (var i = 0; i < 26; i++) {
      final c = String.fromCharCode(65 + i);
      if (c == 'J') continue;
      if (!seen.contains(c)) {
        seen.add(c);
        letters.add(c);
      }
    }

    return List.generate(5, (i) => List.generate(5, (j) => letters[i * 5 + j]));
  }

  Map<String, String> _processPair(String a, String b, List<List<String>> matrix) {
    int rowA = 0, colA = 0, rowB = 0, colB = 0;

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 5; j++) {
        if (matrix[i][j] == a) {
          rowA = i;
          colA = j;
        }
        if (matrix[i][j] == b) {
          rowB = i;
          colB = j;
        }
      }
    }

    if (rowA == rowB) {
      if (isEncrypt) {
        return {
          'rule': 'Same Row → Shift Right',
          'output': '${matrix[rowA][(colA + 1) % 5]}${matrix[rowB][(colB + 1) % 5]}'
        };
      } else {
        return {
          'rule': 'Same Row → Shift Left',
          'output': '${matrix[rowA][(colA + 4) % 5]}${matrix[rowB][(colB + 4) % 5]}'
        };
      }
    } else if (colA == colB) {
      if (isEncrypt) {
        return {
          'rule': 'Same Column → Shift Down',
          'output': '${matrix[(rowA + 1) % 5][colA]}${matrix[(rowB + 1) % 5][colB]}'
        };
      } else {
        return {
          'rule': 'Same Column → Shift Up',
          'output': '${matrix[(rowA + 4) % 5][colA]}${matrix[(rowB + 4) % 5][colB]}'
        };
      }
    } else {
      return {
        'rule': 'Rectangle → Swap Columns',
        'output': '${matrix[rowA][colB]}${matrix[rowB][colA]}'
      };
    }
  }

  Table buildMatrixTable() {
    return Table(
      border: TableBorder.all(),
      defaultColumnWidth: const IntrinsicColumnWidth(),
      children: matrix
          .map(
            (row) => TableRow(
          children: row
              .map((cell) => Padding(
            padding: const EdgeInsets.all(8),
            child: Center(child: Text(cell)),
          ))
              .toList(),
        ),
      )
          .toList(),
    );
  }

  List<TableRow> buildStepsTable() {
    final headers = [
      isEncrypt ? 'Text' : 'Cipher',
      'Key',
      'Rule',
      'Result',
    ];

    return [
      TableRow(
        decoration: const BoxDecoration(color: Colors.indigoAccent),
        children: headers
            .map((h) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(
            h,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ))
            .toList(),
      ),
      ...steps.map((step) {
        return TableRow(
          children: headers
              .map((h) => Padding(
            padding: const EdgeInsets.all(8),
            child: Text(step[h]!),
          ))
              .toList(),
        );
      }).toList(),
    ];
  }

  void reset() {
    inputController.clear();
    keyController.clear();
    setState(() {
      result = '';
      steps.clear();
      showSteps = false;
      matrix = List.generate(5, (_) => List.filled(5, ''));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Playfair Cipher'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: reset,
          )
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ToggleButtons(
                borderRadius: BorderRadius.circular(10),
                isSelected: [isEncrypt, !isEncrypt],
                onPressed: (index) {
                  setState(() {
                    isEncrypt = index == 0;
                    processText();
                  });
                },
                children: const [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Encrypt"),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text("Decrypt"),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: inputController,
                decoration: InputDecoration(
                  labelText: isEncrypt ? 'Enter text' : 'Enter cipher',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (_) => processText(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: keyController,
                decoration: const InputDecoration(
                  labelText: 'Enter key',
                  border: OutlineInputBorder(),
                ),
                onChanged: (_) => processText(),
              ),
              const SizedBox(height: 20),
              if (result.isNotEmpty) ...[
                const Text('Final Result:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text(result,
                    style: const TextStyle(fontSize: 24, color: Colors.blueAccent)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => setState(() => showSteps = !showSteps),
                  child: Text(showSteps ? 'Hide Steps' : 'Show Steps'),
                ),
              ],
              const SizedBox(height: 12),
              if (showSteps && steps.isNotEmpty) ...[
                const Text('5x5 Matrix:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                buildMatrixTable(),
                const SizedBox(height: 20),
                const Text('Transformation Steps:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: buildStepsTable(),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}
