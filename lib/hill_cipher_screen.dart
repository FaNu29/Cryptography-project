import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class HillCipherScreen extends StatefulWidget {
  const HillCipherScreen({super.key});

  @override
  State<HillCipherScreen> createState() => _HillCipherScreenState();
}

class _HillCipherScreenState extends State<HillCipherScreen> {
  final TextEditingController _matrixController = TextEditingController();
  final TextEditingController _textController = TextEditingController();
  bool isEncrypt = true;
  int matrixSize = 3;
  String result = '';
  List<Widget> stepWidgets = [];

  int _det2(List<List<int>> m) => m[0][0] * m[1][1] - m[0][1] * m[1][0];

  int _det3(List<List<int>> m) => m[0][0] * m[1][1] * m[2][2] + m[0][1] * m[1][2] * m[2][0] + m[0][2] * m[1][0] * m[2][1] - m[0][2] * m[1][1] * m[2][0] - m[0][0] * m[1][2] * m[2][1] - m[0][1] * m[1][0] * m[2][2];

  int _modInv(int a, int m) {
    a %= m;
    for (int x = 1; x < m; x++) {
      if ((a * x) % m == 1) return x;
    }
    return -1;
  }

  List<List<int>> _inv2(List<List<int>> m) {
    int det = _det2(m) % 26;
    if (det < 0) det += 26;
    int invDet = _modInv(det, 26);
    stepWidgets.add(_buildText('2×2 det mod26 = $det'));
    stepWidgets.add(_buildText('Inverse det = $invDet'));
    return [
      [(m[1][1] * invDet) % 26, ((-m[0][1] + 26) * invDet) % 26],
      [((-m[1][0] + 26) * invDet) % 26, (m[0][0] * invDet) % 26],
    ];
  }

  List<List<int>> _inv3(List<List<int>> m) {
    int det = _det3(m) % 26;
    if (det < 0) det += 26;
    int invDet = _modInv(det, 26);
    stepWidgets.add(_buildText('3×3 det mod26 = $det'));
    stepWidgets.add(_buildText('Inverse det = $invDet'));
    List<List<int>> cof = List.generate(3, (_) => List.filled(3, 0));
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        List<int> vals = [];
        for (int r = 0; r < 3; r++) {
          for (int c = 0; c < 3; c++) {
            if (r != i && c != j) vals.add(m[r][c]);
          }
        }
        int minor = vals[0] * vals[3] - vals[1] * vals[2];
        int sign = ((i + j) % 2 == 0) ? 1 : -1;
        cof[i][j] = (sign * minor) % 26;
        if (cof[i][j] < 0) cof[i][j] += 26;
      }
    }
    List<List<int>> adj = List.generate(3, (_) => List.filled(3, 0));
    for (int i = 0; i < 3; i++) {
      for (int j = 0; j < 3; j++) {
        adj[i][j] = cof[j][i];
      }
    }
    return List.generate(3, (i) => List.generate(3, (j) => (adj[i][j] * invDet) % 26));
  }

  Widget _buildText(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Text(text, style: GoogleFonts.poppins()),
  );

  Widget _buildMatrix(List<List<int>> m) => Table(
    border: TableBorder.all(),
    children: m
        .map((row) => TableRow(
      children: row
          .map((v) => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(child: Text(v.toString())),
      ))
          .toList(),
    ))
        .toList(),
  );

  void _process() {
    stepWidgets.clear();
    String raw = _textController.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    List<int> nums = raw.runes.map((c) => c - 65).toList();

    String keyText = _matrixController.text.toUpperCase().replaceAll(RegExp(r'[^A-Z]'), '');
    List<int> keyNums = keyText.runes.map((c) => c - 65).toList();
    int targetSize = matrixSize * matrixSize;
    while (keyNums.length < targetSize) keyNums.add(0);
    keyNums = keyNums.sublist(0, targetSize);
    List<List<int>> key = [
      for (int i = 0; i < matrixSize; i++)
        keyNums.sublist(i * matrixSize, i * matrixSize + matrixSize)
    ];

    stepWidgets.add(_buildText('Key matrix (${matrixSize}×$matrixSize) from key text:'));
    stepWidgets.add(_buildMatrix(key));

    // Pad the message with consecutive letters starting from 'Z', 'X', 'Y', ...
    int padCount = matrixSize - (nums.length % matrixSize);
    if (padCount != matrixSize) {
      for (int i = 0; i < padCount; i++) {
        nums.add((25 - i) % 26); // Z = 25, Y = 24, X = 23, etc.
      }
    }

    List<List<int>> matrix = isEncrypt ? key : (matrixSize == 2 ? _inv2(key) : _inv3(key));
    stepWidgets.add(_buildText(isEncrypt ? 'Encrypting...' : 'Decrypting...'));
    StringBuffer out = StringBuffer();
    for (int i = 0; i < nums.length; i += matrixSize) {
      List<int> block = nums.sublist(i, i + matrixSize);
      stepWidgets.add(_buildText('Block vector: ${block.toString()}'));
      stepWidgets.add(_buildMatrix([block]));
      for (int r = 0; r < matrixSize; r++) {
        int sum = 0;
        List<Widget> rowDetail = [];
        for (int c = 0; c < matrixSize; c++) {
          sum += matrix[r][c] * block[c];
          rowDetail.add(_buildText('${matrix[r][c]}×${block[c]}' + (c < matrixSize - 1 ? ' + ' : '')));
        }
        rowDetail.add(_buildText('= $sum'));
        stepWidgets.add(Row(children: rowDetail));
        int modVal = sum % 26;
        stepWidgets.add(_buildText('$sum mod 26 = $modVal'));
        out.writeCharCode(modVal + 65);
      }
    }
    setState(() => result = out.toString());
  }

  @override
  void dispose() {
    _matrixController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hill Cipher', style: GoogleFonts.poppins())),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ToggleButtons(
              isSelected: [isEncrypt, !isEncrypt],
              onPressed: (i) => setState(() => isEncrypt = i == 0),
              children: const [Text('Encrypt'), Text('Decrypt')],
            ),
            const SizedBox(height: 12),
            DropdownButton<int>(
              value: matrixSize,
              items: const [2, 3]
                  .map((e) => DropdownMenuItem(value: e, child: Text('${e}×$e')))
                  .toList(),
              onChanged: (v) => setState(() => matrixSize = v!),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _matrixController,
              decoration: const InputDecoration(
                  labelText: 'Key text (e.g. MONARCHY)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _textController,
              decoration: InputDecoration(
                  labelText: isEncrypt ? 'Plaintext' : 'Ciphertext',
                  border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: _process, child: Text('Run', style: GoogleFonts.poppins())),
            if (result.isNotEmpty) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Text('Result: $result',
                        style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy',
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: result));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Result copied to clipboard!')),
                      );
                    },
                  )
                ],
              ),
            ],
            const SizedBox(height: 16),
            Expanded(child: SingleChildScrollView(child: Column(children: stepWidgets)))
          ],
        ),
      ),
    );
  }
}