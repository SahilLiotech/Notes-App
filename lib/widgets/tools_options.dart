import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ToolsOptions extends StatelessWidget {
  final IconData? iconData;
  final String text;
  final VoidCallback onTap;
  const ToolsOptions({
    super.key,
    required this.iconData,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Color(0xFF6C63FF).withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.transparent, width: 2),
        ),
        child: Row(
          spacing: 4,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, color: Color(0xFF6C63FF)),
            Text(
              text,
              style: GoogleFonts.poppins(
                color: Color(0xFF6C63FF),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
