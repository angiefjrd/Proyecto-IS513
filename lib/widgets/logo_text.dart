import 'package:flutter/material.dart';

class LogoText extends StatelessWidget {
  final double fontSize;

  const LogoText({
    super.key,
    this.fontSize = 24, 
    });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Writer',
          style: TextStyle(
            color: const Color.fromRGBO(255, 255, 255, 1),
            fontWeight: FontWeight.bold,
            fontSize: fontSize,
            fontFamily: 'Arial',
          ),
        ),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color.fromRGBO(66, 0, 104, 1), // #420068
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            'hub',
            style: TextStyle(
              color: const Color.fromRGBO(0, 0, 0, 1),
              fontWeight: FontWeight.bold,
              fontSize: fontSize * 0.85, // slightly smaller for contrast
              fontFamily: 'Arial',
            ),
          ),
        ),
      ],
    );
  }
}