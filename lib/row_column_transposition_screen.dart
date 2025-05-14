import 'package:flutter/material.dart';

class RowColumnTranspositionScreen extends StatefulWidget {
  const RowColumnTranspositionScreen({super.key});

  @override
  State<RowColumnTranspositionScreen> createState() => _RowColumnTranspositionScreenState();
}

class _RowColumnTranspositionScreenState extends State<RowColumnTranspositionScreen> {
  final textController = TextEditingController();
  final keyController = TextEditingController();

  bool isEncrypt = true;
  String result = '';
  bool showVisualization = false;

  List<List<String>> matrix = [];
  List<Map<String, dynamic>> steps = [];

  void process() {
    final text = textController.text.replaceAll(' ', '').toUpperCase();
    final key = keyController.text.toUpperCase();

    if (text.isEmpty || key.isEmpty) {
      setState(() {
        result = '';
        matrix = [];
        steps = [];
        showVisualization = false;
      });
      return;
    }

    final columnOrder = getKeyOrder(key);
    if (isEncrypt) {
      encrypt(text, columnOrder);
    } else {
      decrypt(text, columnOrder);
    }
  }

  List<int> getKeyOrder(String key) {
    final letters = key.split('');
    final sorted = [...letters]..sort();
    return letters.map((char) => sorted.indexOf(char)).toList();
  }

  void encrypt(String text, List<int> columnOrder) {
    steps.clear();
    matrix.clear();

    final columns = columnOrder.length;
    final rows = (text.length / columns).ceil();
    List<List<String>> grid = List.generate(rows, (_) => List.filled(columns, ''));

    int index = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        if (index < text.length) {
          grid[r][c] = text[index++];
        } else {
          grid[r][c] = 'X'; // Padding
        }
      }
    }

    StringBuffer buffer = StringBuffer();

    for (int i = 0; i < columns; i++) {
      int colIndex = columnOrder.indexOf(i);
      String colText = '';
      for (int r = 0; r < rows; r++) {
        colText += grid[r][colIndex];
        buffer.write(grid[r][colIndex]);
      }
      steps.add({
        'Column': i + 1,
        'Index': colIndex,
        'Content': colText,
      });
    }

    setState(() {
      result = buffer.toString();
      matrix = grid;
    });
  }

  void decrypt(String cipher, List<int> columnOrder) {
    steps.clear();
    matrix.clear();

    final columns = columnOrder.length;
    final rows = (cipher.length / columns).ceil();
    List<List<String>> grid = List.generate(rows, (_) => List.filled(columns, ''));

    int index = 0;
    for (int i = 0; i < columns; i++) {
      int colIndex = columnOrder.indexOf(i);
      String colText = '';
      for (int r = 0; r < rows; r++) {
        if (index < cipher.length) {
          grid[r][colIndex] = cipher[index++];
          colText += grid[r][colIndex];
        }
      }
      steps.add({
        'Column': i + 1,
        'Index': colIndex,
        'Content': colText,
      });
    }

    StringBuffer buffer = StringBuffer();
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < columns; c++) {
        buffer.write(grid[r][c]);
      }
    }

    setState(() {
      result = buffer.toString();
      matrix = grid;
    });
  }

  List<TableRow> buildMatrixTable() {
    return matrix.map((row) {
      return TableRow(
        children: row.map((cell) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(cell)),
          );
        }).toList(),
      );
    }).toList();
  }

  List<TableRow> buildStepsTable() {
    return [
      TableRow(
        decoration: const BoxDecoration(color: Colors.indigoAccent),
        children: const [
          Padding(padding: EdgeInsets.all(8), child: Text('Column', style: TextStyle(color: Colors.white))),
          Padding(padding: EdgeInsets.all(8), child: Text('Index', style: TextStyle(color: Colors.white))),
          Padding(padding: EdgeInsets.all(8), child: Text('Content', style: TextStyle(color: Colors.white))),
        ],
      ),
      ...steps.map((step) {
        return TableRow(children: [
          Padding(padding: const EdgeInsets.all(8), child: Text(step['Column'].toString())),
          Padding(padding: const EdgeInsets.all(8), child: Text(step['Index'].toString())),
          Padding(padding: const EdgeInsets.all(8), child: Text(step['Content'].toString())),
        ]);
      })
    ];
  }

  void reset() {
    textController.clear();
    keyController.clear();
    setState(() {
      result = '';
      matrix.clear();
      steps.clear();
      showVisualization = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Row-Column Transposition Cipher'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: reset, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isEncrypt, !isEncrypt],
              onPressed: (index) {
                setState(() {
                  isEncrypt = index == 0;
                  process();
                });
              },
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Encrypt')),
                Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text('Decrypt')),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              decoration: InputDecoration(
                labelText: isEncrypt ? 'Enter Text' : 'Enter Cipher Text',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => process(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Enter Key (text or number)',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => process(),
            ),
            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Result:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text(result, style: const TextStyle(fontSize: 20, color: Colors.blueAccent)),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: () => setState(() => showVisualization = !showVisualization),
                    child: Text(showVisualization ? 'Hide Visualization' : 'Show Visualization'),
                  ),
                ],
              ),
            const SizedBox(height: 12),
            if (showVisualization)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Matrix:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Table(border: TableBorder.all(), children: buildMatrixTable()),
                      const SizedBox(height: 16),
                      const Text('Step-by-Step Calculation:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Table(border: TableBorder.all(), children: buildStepsTable()),
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
