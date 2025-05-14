import 'package:flutter/material.dart';

class VigenereCipherScreen extends StatefulWidget {
  const VigenereCipherScreen({super.key});

  @override
  State<VigenereCipherScreen> createState() => _VigenereCipherScreenState();
}

class _VigenereCipherScreenState extends State<VigenereCipherScreen> {
  final TextEditingController textController = TextEditingController();
  final TextEditingController keyController = TextEditingController();
  String result = '';
  bool isEncrypt = true;
  bool showTable = false;
  List<Map<String, dynamic>> steps = [];

  void processText() {
    final rawInput = textController.text.toUpperCase();
    final rawKey = keyController.text.toUpperCase();

    if (rawInput.isEmpty || rawKey.isEmpty) {
      setState(() {
        result = '';
        steps.clear();
        showTable = false;
      });
      return;
    }

    final input = rawInput;
    final key = rawKey;
    final buffer = StringBuffer();
    steps.clear();
    int keyIndex = 0;

    for (int i = 0; i < input.length; i++) {
      final char = input[i];
      if (RegExp(r'[A-Z]').hasMatch(char)) {
        final inputNum = char.codeUnitAt(0) - 65;
        final keyChar = key[keyIndex % key.length];
        final keyNum = keyChar.codeUnitAt(0) - 65;

        int newCharNum;
        if (isEncrypt) {
          newCharNum = (inputNum + keyNum) % 26;
        } else {
          newCharNum = (inputNum - keyNum + 26) % 26;
        }

        final newChar = String.fromCharCode(65 + newCharNum);
        buffer.write(newChar);

        steps.add({
          isEncrypt ? 'Text' : 'Cipher': char,
          isEncrypt ? 'Text#' : 'Cipher#': inputNum,
          'Key': keyChar,
          'Key#': keyNum,
          'Calc': isEncrypt
              ? '($inputNum + $keyNum) % 26 = $newCharNum'
              : '($inputNum - $keyNum + 26) % 26 = $newCharNum',
          'Result': newChar,
        });

        keyIndex++;
      } else {
        buffer.write(char);
        steps.add({
          isEncrypt ? 'Text' : 'Cipher': char,
          isEncrypt ? 'Text#' : 'Cipher#': '-',
          'Key': '-',
          'Key#': '-',
          'Calc': '-',
          'Result': char,
        });
      }
    }

    setState(() {
      result = buffer.toString();
    });
  }

  void reset() {
    textController.clear();
    keyController.clear();
    setState(() {
      result = '';
      steps.clear();
      showTable = false;
    });
  }

  List<String> getRowHeaders() {
    return isEncrypt
        ? ['Text', 'Text#', 'Key', 'Key#', 'Calc', 'Result']
        : ['Cipher', 'Cipher#', 'Key', 'Key#', 'Calc', 'Result'];
  }

  List<TableRow> buildTransposedTable() {
    final rowHeaders = getRowHeaders();
    final List<TableRow> rows = [];

    for (String header in rowHeaders) {
      List<Widget> cells = [
        Container(
          padding: const EdgeInsets.all(8),
          color: Colors.indigo.shade100,
          child: Text(
            header,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ];

      for (var step in steps) {
        cells.add(
          Container(
            padding: const EdgeInsets.all(8),
            child: Text(step[header].toString()),
          ),
        );
      }
      rows.add(TableRow(children: cells));
    }
    return rows;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vigenère Cipher'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset',
            onPressed: reset,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
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
              controller: textController,
              decoration: InputDecoration(
                labelText: isEncrypt ? 'Enter Text' : 'Enter Cipher Text',
                border: const OutlineInputBorder(),
              ),
              onChanged: (_) => processText(),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: keyController,
              decoration: const InputDecoration(
                labelText: 'Enter Key',
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => processText(),
            ),
            const SizedBox(height: 20),
            if (result.isNotEmpty)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isEncrypt ? 'Encrypted Result:' : 'Decrypted Result:',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    result,
                    style: const TextStyle(
                        fontSize: 24, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => setState(() => showTable = !showTable),
                    child: Text(showTable
                        ? 'Hide Step-by-Step'
                        : 'Show Step-by-Step'),
                  )
                ],
              ),
            const SizedBox(height: 12),
            if (showTable && steps.isNotEmpty)
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Table(
                    border: TableBorder.all(),
                    defaultColumnWidth: const IntrinsicColumnWidth(),
                    children: buildTransposedTable(),
                  ),
                ),
              )
          ],
        ),
      ),
    );
  }
}
