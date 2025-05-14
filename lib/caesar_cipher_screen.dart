import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CaesarCipherScreen extends StatefulWidget {
  const CaesarCipherScreen({super.key});

  @override
  State<CaesarCipherScreen> createState() => _CaesarCipherScreenState();
}

class _CaesarCipherScreenState extends State<CaesarCipherScreen> {
  String inputText = '';
  String finalResult = '';
  int shift = 3;
  bool isEncrypt = true;
  List<Map<String, String>> visualizationSteps = [];
  bool showVisualization = false;

  final TextEditingController _controller = TextEditingController();

  // Caesar Cipher logic
  String caesarCipher(String text, int shift, bool encrypt) {
    final buffer = StringBuffer();
    visualizationSteps.clear();

    for (var char in text.toUpperCase().runes) {
      String originalChar = String.fromCharCode(char);
      if (char >= 65 && char <= 90) {
        int base = 65;
        int offset = encrypt
            ? (char - base + shift) % 26
            : (char - base - shift + 26) % 26;
        String resultChar = String.fromCharCode(base + offset);
        buffer.write(resultChar);
        visualizationSteps.add({
          'original': originalChar,
          'result': resultChar,
        });
      } else {
        buffer.write(originalChar);
        visualizationSteps.add({
          'original': originalChar,
          'result': originalChar,
        });
      }
    }
    return buffer.toString();
  }

  void updateVisualization() {
    setState(() {
      finalResult = caesarCipher(inputText, shift, isEncrypt);
      showVisualization = true;
    });
  }

  void resetFields() {
    setState(() {
      _controller.clear();
      inputText = '';
      finalResult = '';
      shift = 3;
      isEncrypt = true;
      showVisualization = false;
      visualizationSteps.clear();
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // clean up
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Caesar Cipher Visualizer'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reload',
            onPressed: resetFields,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Encrypt / Decrypt Toggle
            ToggleButtons(
              borderRadius: BorderRadius.circular(10),
              isSelected: [isEncrypt, !isEncrypt],
              onPressed: (index) {
                setState(() {
                  isEncrypt = index == 0;
                  if (inputText.isNotEmpty) {
                    finalResult = caesarCipher(inputText, shift, isEncrypt);
                  }
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

            // Shift Slider
            Row(
              children: [
                Text("Shift:", style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
                Expanded(
                  child: Slider(
                    value: shift.toDouble(),
                    min: 1,
                    max: 25,
                    divisions: 24,
                    label: shift.toString(),
                    onChanged: (val) {
                      setState(() {
                        shift = val.toInt();
                        if (inputText.isNotEmpty) {
                          finalResult = caesarCipher(inputText, shift, isEncrypt);
                        }
                      });
                    },
                  ),
                ),
                Text(shift.toString(), style: GoogleFonts.poppins()),
              ],
            ),
            const SizedBox(height: 16),

            // Input Text Field
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: 'Enter text',
                labelStyle: GoogleFonts.poppins(),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (val) {
                setState(() {
                  inputText = val;
                  finalResult = caesarCipher(inputText, shift, isEncrypt);
                  showVisualization = false; // reset steps if user types again
                });
              },
            ),
            const SizedBox(height: 16),

            // Final Output (Real-time)
            if (finalResult.isNotEmpty) ...[
              const Text('Final Result:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Text(
                  finalResult,
                  key: ValueKey(finalResult),
                  style: const TextStyle(fontSize: 28, color: Colors.blue),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Show Visualize Button Only When Input Exists
            if (inputText.trim().isNotEmpty) ...[
              ElevatedButton.icon(
                onPressed: updateVisualization,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Visualize Steps'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: GoogleFonts.poppins(fontSize: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Step-by-step Visualization
            if (showVisualization && visualizationSteps.isNotEmpty) ...[
              const Text('Step-by-Step Visualization:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: visualizationSteps.map((step) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.indigo.shade700),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(step['original'] ?? '',
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        const Icon(Icons.arrow_downward, size: 18),
                        Text(step['result'] ?? '',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: isEncrypt ? Colors.green : Colors.red)),
                      ],
                    ),
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
