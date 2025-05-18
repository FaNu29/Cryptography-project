import 'package:flutter/material.dart';
import 'dart:math';

class EulerTheoremScreen extends StatefulWidget {
  const EulerTheoremScreen({super.key});

  @override
  State<EulerTheoremScreen> createState() => _EulerTheoremScreenState();
}

class _EulerTheoremScreenState extends State<EulerTheoremScreen> {
  final TextEditingController baseController = TextEditingController();
  final TextEditingController expController = TextEditingController();
  final TextEditingController modController = TextEditingController();

  List<String> steps = [];
  String result = '';
  bool showSteps = false;

  void computeEulerTheorem() {
    final int? base = int.tryParse(baseController.text);
    final int? exp = int.tryParse(expController.text);
    final int? mod = int.tryParse(modController.text);

    if (base == null || exp == null || mod == null || mod <= 1) {
      setState(() {
        result = '';
        steps = ['⚠ Please enter valid integers. Modulus must be > 1.'];
      });
      return;
    }

    final solver = EulerTheoremSolver(base: base, exponent: exp, modulus: mod);
    final answer = solver.solve();

    setState(() {
      result = answer >= 0 ? answer.toString() : 'Invalid';
      steps = solver.steps;
    });
  }

  void reset() {
    baseController.clear();
    expController.clear();
    modController.clear();
    setState(() {
      result = '';
      steps.clear();
      showSteps = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Euler\'s Theorem Solver'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: reset,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: baseController,
                decoration: const InputDecoration(
                  labelText: 'Base (x)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => computeEulerTheorem(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: expController,
                decoration: const InputDecoration(
                  labelText: 'Exponent (k)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => computeEulerTheorem(),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: modController,
                decoration: const InputDecoration(
                  labelText: 'Modulus (n)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => computeEulerTheorem(),
              ),
              const SizedBox(height: 20),
              if (result.isNotEmpty) ...[
                const Text('Result:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Answer: $result',
                    style: const TextStyle(fontSize: 24, color: Colors.blue)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showSteps = !showSteps;
                    });
                  },
                  child: Text(showSteps ? 'Hide Steps' : 'Show Steps'),
                ),
              ],
              if (showSteps && steps.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Text('Calculation Steps:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                for (final step in steps)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text('• $step'),
                  ),
              ]
            ],
          ),
        ),
      ),
    );
  }
}

class EulerTheoremSolver {
  final int base;
  final int exponent;
  final int modulus;
  final List<String> steps = [];

  EulerTheoremSolver({
    required this.base,
    required this.exponent,
    required this.modulus,
  });

  int _gcd(int a, int b) => b == 0 ? a : _gcd(b, a % b);

  int _phi(int n) {
    int result = n;
    for (int i = 2; i * i <= n; i++) {
      if (n % i == 0) {
        while (n % i == 0) {
          n ~/= i;
        }
        result -= result ~/ i;
      }
    }
    if (n > 1) result -= result ~/ n;
    return result;
  }

  int _modPow(int base, int exp, int mod) {
    int result = 1;
    base %= mod;
    while (exp > 0) {
      if (exp % 2 == 1) {
        result = (result * base) % mod;
      }
      base = (base * base) % mod;
      exp ~/= 2;
    }
    return result;
  }

  int solve() {
    steps.clear();

    if (_gcd(base, modulus) != 1) {
      steps.add("⚠ $base and $modulus are not coprime. Euler's theorem can't be applied.");
      return -1;
    }

    steps.add("Given: $base^$exponent mod $modulus");
    int phiN = _phi(modulus);
    steps.add("φ($modulus) = $phiN");

    steps.add("By Euler's Theorem: $base^$phiN ≡ 1 mod $modulus");

    int q = exponent ~/ phiN;
    int r = exponent % phiN;

    steps.add("$base^$exponent = $base^($phiN × $q + $r)");
    steps.add("⇒ ($base^$phiN)^$q × $base^$r mod $modulus");
    steps.add("$base^$phiN ≡ 1 ⇒ (1^$q × ${base}^$r) mod $modulus");

    int part = _modPow(base, r, modulus);
    steps.add("${base}^$r mod $modulus = $part");

    steps.add("Final Result = 1 × $part = $part");

    return part;
  }
}