import 'package:crpto/Hill_Cipher_screen.dart';
import 'package:crpto/euler_fermat_screen.dart';
import 'package:crpto/modular_arithmetic_screen.dart';
import 'package:crpto/playfair_cipher_screen.dart';
import 'package:crpto/rail_fence_screen.dart';
import 'package:crpto/row_column_transposition_screen.dart';
import 'package:crpto/vigenere_cipher_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Game.dart';
import 'caesar_cipher_screen.dart';
import 'double_transposition_screen.dart';

class AlgorithmListPage extends StatelessWidget {
  const AlgorithmListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Encryption Algorithms',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: const Color(0xffffffff),  // purple color from your gradient
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors:[Color(0xffb683d1), Color(0xff5184d6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 100),
          children: [
            _buildAlgorithmItem(
              context,
              icon: Icons.lock_outline,
              title: 'Game',
              description: 'Encrypt/Decrypt with a shift value.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EscapeRoomPuzzle()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.lock_outline,
              title: 'Caesar Cipher',
              description: 'Encrypt/Decrypt with a shift value.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const CaesarCipherScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.timeline,
              title: 'Rail Fence Cipher',
              description: 'Encrypt/Decrypt with a zig-zag pattern.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RailFenceScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.vpn_key,
              title: 'Vigenère Cipher',
              description: 'Encrypt/Decrypt with a key word.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const VigenereCipherScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.grid_on,
              title: 'Playfair Cipher',
              description: 'Encrypt/Decrypt using digraphs.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PlayfairCipherScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.grid_view_sharp,
              title: 'Hill Cipher',
              description: 'Encrypt/Decrypt using digraphs.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HillCipherScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.table_chart,
              title: 'Row-Column Transposition',
              description: 'Encrypt/Decrypt using row-column order.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RowColumnTranspositionScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.all_inclusive,
              title: 'Double Transposition',
              description: 'Encrypt/Decrypt with double permutation.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const DoubleTranspositionScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.calculate,
              title: 'Modular Arithmetic',
              description: 'Encrypt/Decrypt using modular operations.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ModularArithmeticScreen()),
              ),
            ),
            _buildAlgorithmItem(
              context,
              icon: Icons.functions,
              title: 'Euler/Fermat Theorem',
              description: 'Encrypt/Decrypt using number theory.',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const EulerTheoremScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlgorithmItem(
      BuildContext context, {
        required IconData icon,
        required String title,
        required String description,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.white.withOpacity(0.3),
              child: Icon(icon, color: Colors.white),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}