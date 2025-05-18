import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DoubleTranspositionScreen extends StatefulWidget {
  const DoubleTranspositionScreen({super.key});

  @override
  State<DoubleTranspositionScreen> createState() => _DoubleTranspositionScreenState();
}

class _DoubleTranspositionScreenState extends State<DoubleTranspositionScreen> {
  final textController = TextEditingController();
  final rowKeyController = TextEditingController();
  final colKeyController = TextEditingController();

  bool isEncrypt = true;
  String result = '';
  bool showVisualization = false;

  List<List<String>> matrix = [];
  List<Map<String, dynamic>> rowSteps = [];
  List<Map<String, dynamic>> colSteps = [];

  void process() {
    final text = textController.text.replaceAll(' ', '').toUpperCase();
    final rowKey = rowKeyController.text;
    final colKey = colKeyController.text;

    if (text.isEmpty || rowKey.isEmpty || colKey.isEmpty) {
      setState(() {
        result = '';
        matrix.clear();
        rowSteps.clear();
        colSteps.clear();
        showVisualization = false;
      });
      return;
    }

    try {
      final rowOrder = rowKey.trim().split('').map((c) {
        if (!RegExp(r'\d').hasMatch(c)) throw FormatException();
        return int.parse(c);
      }).toList();

      final colOrder = colKey.trim().split('').map((c) {
        if (!RegExp(r'\d').hasMatch(c)) throw FormatException();
        return int.parse(c);
      }).toList();

      if (isEncrypt) {
        encrypt(text, rowOrder, colOrder);
      } else {
        decrypt(text, rowOrder, colOrder);
      }
    } catch (e) {
      setState(() {
        result = 'Invalid key! Use digits only.';
        matrix.clear();
        rowSteps.clear();
        colSteps.clear();
        showVisualization = false;
      });
    }
  }

  void encrypt(String text, List<int> rowOrder, List<int> colOrder) {
    rowSteps.clear();
    colSteps.clear();

    final rows = rowOrder.length;
    final cols = colOrder.length;
    List<List<String>> grid = List.generate(rows, (_) => List.filled(cols, 'X'));

    int index = 0;
    for (int r = 0; r < rows; r++) {
      for (int c = 0; c < cols; c++) {
        if (index < text.length) {
          grid[r][c] = text[index++];
        }
      }
    }

    // Save original grid
    List<List<String>> original = grid.map((e) => [...e]).toList();

    // Row Transposition
    List<MapEntry<int, List<String>>> rowIndexed = [];
    for (int i = 0; i < rows; i++) {
      rowIndexed.add(MapEntry(rowOrder[i], grid[i]));
    }
    rowIndexed.sort((a, b) => a.key.compareTo(b.key));
    List<List<String>> rowTransposed = rowIndexed.map((e) => e.value).toList();
    for (int i = 0; i < rows; i++) {
      rowSteps.add({'Order': rowOrder[i], 'Row': original[i].join('')});
    }

    // Column Transposition
    List<List<String>> finalGrid = List.generate(rows, (_) => List.filled(cols, ''));
    for (int c = 0; c < cols; c++) {
      int newC = colOrder.indexOf(c);
      for (int r = 0; r < rows; r++) {
        finalGrid[r][c] = rowTransposed[r][newC];
      }

      String colText = '';
      for (int r = 0; r < rows; r++) {
        colText += finalGrid[r][c];
      }
      colSteps.add({'Column': c + 1, 'Mapped From': newC + 1, 'Content': colText});
    }

    StringBuffer buffer = StringBuffer();
    for (var row in finalGrid) {
      for (var ch in row) {
        buffer.write(ch);
      }
    }

    setState(() {
      result = buffer.toString();
      matrix = finalGrid;
    });
  }

  void decrypt(String text, List<int> rowOrder, List<int> colOrder) {
    // Decryption can be added here.
    setState(() {
      result = 'Decryption not implemented in this demo.';
      matrix.clear();
      rowSteps.clear();
      colSteps.clear();
      showVisualization = false;
    });
  }

  List<TableRow> buildMatrixTable() {
    return matrix.map((row) {
      return TableRow(
        children: row.map((cell) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(child: Text(cell, style: const TextStyle(fontSize: 18))),
          );
        }).toList(),
      );
    }).toList();
  }

  List<TableRow> buildStepTable(List<Map<String, dynamic>> steps, List<String> headers) {
    return [
      TableRow(
        decoration: const BoxDecoration(color: Colors.indigo),
        children: headers
            .map((header) => Padding(
          padding: const EdgeInsets.all(8),
          child: Text(header,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ))
            .toList(),
      ),
      ...steps.map((step) {
        return TableRow(
          children: headers.map((h) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: Text(step[h].toString(), style: const TextStyle(fontSize: 16)),
            );
          }).toList(),
        );
      }).toList(),
    ];
  }

  void reset() {
    textController.clear();
    rowKeyController.clear();
    colKeyController.clear();
    setState(() {
      result = '';
      matrix.clear();
      rowSteps.clear();
      colSteps.clear();
      showVisualization = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Double Transposition Cipher'),
        centerTitle: true,
        actions: [IconButton(onPressed: reset, icon: const Icon(Icons.refresh))],
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
                labelText: isEncrypt ? 'Enter Plaintext' : 'Enter Ciphertext',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => process(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: rowKeyController,
              decoration: const InputDecoration(
                labelText: 'Row Key (digits only)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => process(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: colKeyController,
              decoration: const InputDecoration(
                labelText: 'Column Key (digits only)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => process(),
            ),
            const SizedBox(height: 16),
            if (result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Final Result:',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
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
                      const Text('Matrix:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      const SizedBox(height: 8),
                      Table(border: TableBorder.all(), children: buildMatrixTable()),
                      const SizedBox(height: 16),
                      const Text('Row Transposition Steps:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Table(
                        border: TableBorder.all(),
                        children: buildStepTable(rowSteps, ['Order', 'Row']),
                      ),
                      const SizedBox(height: 16),
                      const Text('Column Transposition Steps:',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Table(
                        border: TableBorder.all(),
                        children: buildStepTable(colSteps, ['Column', 'Mapped From', 'Content']),
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
