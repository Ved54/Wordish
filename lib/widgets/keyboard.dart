import 'package:flutter/material.dart';

class Keyboard extends StatelessWidget {
  final Function(String) onKeyPressed;

  const Keyboard({super.key, required this.onKeyPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildRow(['Q', 'W', 'E', 'R', 'T', 'Y', 'U', 'I', 'O', 'P']),
        const SizedBox(height: 8),
        _buildRow(['A', 'S', 'D', 'F', 'G', 'H', 'J', 'K', 'L']),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildKey('ENTER', isSpecial: true),
            ..._buildRow(['Z', 'X', 'C', 'V', 'B', 'N', 'M']).children,
          ],
        ),
        const SizedBox(height: 8),
        _buildKey('BACKSPACE', isSpecial: true),
      ],
    );
  }

  Row _buildRow(List<String> letters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: letters.map((letter) => _buildKey(letter)).toList(),
    );
  }

  Widget _buildKey(String key, {bool isSpecial = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2.0),
      child: GestureDetector(
        onTap: () => onKeyPressed(key),
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: isSpecial ? Colors.blueGrey : Colors.grey[300],
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            key,
            style: TextStyle(
              fontSize: isSpecial ? 12 : 16,
              fontWeight: FontWeight.bold,
              color: isSpecial ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
