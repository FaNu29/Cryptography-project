import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RailFenceScreen extends StatefulWidget {
  const RailFenceScreen({super.key});

  @override
  State<RailFenceScreen> createState() => _RailFenceScreenState();
}

class _RailFenceScreenState extends State<RailFenceScreen> {
  final TextEditingController _textController = TextEditingController();
  final TextEditingController _keyController = TextEditingController(text: '3');
  String result = '';
  bool isEncrypt = true;
  bool showMatrix = false;

  List<List<String>> railMatrix = [];

  void handleProcess({bool visualOnly = false}) {
    final key = int.tryParse(_keyController.text);
    final text = _textController.text;

    if (key == null || key < 2 || text.isEmpty) return;

    if (visualOnly) {
      setState(() {
        showMatrix = true;
        isEncrypt ? encryptRailFence(text, key) : decryptRailFence(text, key);
      });
    } else {
      setState(() {
        showMatrix = false;
        result = isEncrypt
            ? encryptRailFence(text, key)
            : decryptRailFence(text, key);
      });
    }
  }

  String encryptRailFence(String text, int key) {
    List<List<String>> rail = List.generate(key, (_) => List.filled(text.length, ' ', growable: false));
    int row = 0, dir = 1;

    for (int i = 0; i < text.length; i++) {
      rail[row][i] = text[i];
      row += dir;
      if (row == 0 || row == key - 1) dir *= -1;
    }

    railMatrix = rail;
    return rail.expand((r) => r.where((c) => c != ' ')).join();
  }

  String decryptRailFence(String text, int key) {
    List<List<String>> rail = List.generate(key, (_) => List.filled(text.length, ' ', growable: false));
    int row = 0, dir = 1;

    for (int i = 0; i < text.length; i++) {
      rail[row][i] = '*';
      row += dir;
      if (row == 0 || row == key - 1) dir *= -1;
    }

    int index = 0;
    for (int r = 0; r < key; r++) {
      for (int c = 0; c < text.length; c++) {
        if (rail[r][c] == '*' && index < text.length) {
          rail[r][c] = text[index++];
        }
      }
    }

    railMatrix = rail;

    StringBuffer result = StringBuffer();
    row = 0;
    dir = 1;
    for (int i = 0; i < text.length; i++) {
      result.write(rail[row][i]);
      row += dir;
      if (row == 0 || row == key - 1) dir *= -1;
    }

    return result.toString();
  }

  @override
  Widget build(BuildContext context) {
    final themeText = GoogleFonts.poppins();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rail Fence Cipher'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _textController.clear();
                _keyController.text = '3';
                result = '';
                railMatrix.clear();
                showMatrix = false;
                isEncrypt = true;
              });
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ToggleButtons(
              isSelected: [isEncrypt, !isEncrypt],
              onPressed: (index) {
                setState(() => isEncrypt = index == 0);
                handleProcess();
              },
              borderRadius: BorderRadius.circular(10),
              children: const [
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Encrypt")),
                Padding(padding: EdgeInsets.symmetric(horizontal: 20), child: Text("Decrypt")),
              ],
            ),
            const SizedBox(height: 16),

            // Depth before text
            TextField(
              controller: _keyController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Depth (Number of Rails)",
                labelStyle: themeText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => handleProcess(),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _textController,
              decoration: InputDecoration(
                labelText: "Enter text",
                labelStyle: themeText,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (_) => handleProcess(),
            ),
            const SizedBox(height: 16),

            if (result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Result:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      result,
                      key: ValueKey(result),
                      style: const TextStyle(fontSize: 24, color: Colors.teal),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            ElevatedButton.icon(
              onPressed: () => handleProcess(visualOnly: true),
              icon: const Icon(Icons.grid_4x4),
              label: const Text("Show Rail Matrix"),
            ),

            const SizedBox(height: 16),

            if (showMatrix && railMatrix.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Rail Matrix Visualization:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),

                  // Make it horizontally scrollable
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Table(
                      border: TableBorder.all(color: Colors.black12),
                      defaultColumnWidth: const IntrinsicColumnWidth(),
                      children: railMatrix.map((row) {
                        return TableRow(
                          children: row.map((char) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              alignment: Alignment.center,
                              color: char == ' ' ? Colors.transparent : Colors.indigo[50],
                              child: Text(
                                char == ' ' ? '' : char,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            );
                          }).toList(),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
