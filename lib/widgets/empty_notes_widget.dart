import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EmptyNotesWidget extends StatelessWidget {
  const EmptyNotesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey.shade300),

          Text(
            'No notes yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              color: Colors.grey.shade400,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            'Create your first note by tapping the + button',
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey.shade400,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
