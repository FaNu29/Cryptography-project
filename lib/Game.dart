import 'package:flutter/material.dart';
import 'package:encrypt/encrypt.dart' as encrypt;

class EscapeRoomPuzzle extends StatefulWidget {
  const EscapeRoomPuzzle({Key? key}) : super(key: key);

  @override
  _EscapeRoomPuzzleState createState() => _EscapeRoomPuzzleState();
}

class _EscapeRoomPuzzleState extends State<EscapeRoomPuzzle> {
  final encrypt.Key key = encrypt.Key.fromUtf8('my32lengthsupersecretkey12345678');
  final encrypt.IV iv = encrypt.IV.fromUtf8('8bytesiv12345678');
  late encrypt.Encrypter encrypter;

  int currentRound = 0;
  final TextEditingController answerController = TextEditingController();
  String message = '';
  String lastEncryptedClue = '';

  final List<Map<String, dynamic>> rounds = [
    // Mixed AES & DES questions
    {
      'question': '1) How many key sizes does AES support? (Enter a number)',
      'answer': '3',
      'clue': 'AES supports 3 key sizes.',
    },
    {
      'question': '2) What is the key size of DES (in bits)?',
      'answer': '56',
      'clue': 'DES uses a 56-bit key.',
    },
    {
      'question': '3) How many rounds does DES use?',
      'answer': '16',
      'clue': 'DES uses 16 rounds of encryption.',
    },
    {
      'question': '4) Which AES version has the strongest key size?',
      'answer': 'AES-256',
      'clue': 'AES-256 has the longest and strongest key.',
    },
    {
      'question': '5) What is the block size of AES (in bits)?',
      'answer': '128',
      'clue': 'AES block size is 128 bits.',
    },
    {
      'question': '6) Which algorithm replaced DES as a stronger standard?',
      'answer': 'AES',
      'clue': 'AES replaced DES as the stronger encryption standard.',
    },
    {
      'question': '7) What does AES stand for?',
      'answer': 'Advanced Encryption Standard',
      'clue': 'AES means Advanced Encryption Standard.',
    },
    {
      'question': '8) What is the block size of DES (in bits)?',
      'answer': '64',
      'clue': 'DES processes 64-bit blocks.',
    },
    {
      'question': '9) How many rounds does AES-128 use? (Enter a number)',
      'answer': '10',
      'clue': 'AES-128 uses 10 rounds.',
    },
    {
      'question': '10) DES is a type of what cipher?',
      'answer': 'Block cipher',
      'clue': 'DES is a block cipher.',
    },
  ];

  @override
  void initState() {
    super.initState();
    encrypter = encrypt.Encrypter(encrypt.AES(key));
  }

  String encryptClue(String clue) {
    final encrypted = encrypter.encrypt(clue, iv: iv);
    return encrypted.base64;
  }

  void checkAnswer() {
    final userAnswer = answerController.text.trim().toLowerCase();
    final correctAnswer = (rounds[currentRound]['answer'] as String).toLowerCase();
    final clue = rounds[currentRound]['clue'] as String;

    if (userAnswer == correctAnswer) {
      final encryptedClue = encryptClue(clue);
      setState(() {
        lastEncryptedClue = encryptedClue;
        if (currentRound == rounds.length - 1) {
          message = '🎉 You escaped the room!\n\nEncrypted Clue:\n$encryptedClue';
        } else {
          message = '✅ Correct!\n\nEncrypted Clue:\n$encryptedClue';
          currentRound++;
          answerController.clear();
        }
      });
    } else {
      setState(() {
        message = '❌ Wrong answer. Try again!';
      });
    }
  }

  @override
  void dispose() {
    answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const gradientColors = [Color(0xffb683d1), Color(0xff5184d6)];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('🔐 Escape Room'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: gradientColors,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        elevation: 4,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Card(
              elevation: 5,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  rounds[currentRound]['question'] as String,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: answerController,
              decoration: InputDecoration(
                labelText: 'Your answer',
                hintText: 'Type your answer here',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: ElevatedButton.icon(
                icon: const Icon(Icons.check),
                label: const Text('Submit'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: checkAnswer,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    message,
                    style: const TextStyle(fontSize: 16, color: Colors.black87),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
