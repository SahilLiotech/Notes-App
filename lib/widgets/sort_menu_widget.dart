import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/notes_provider.dart';

class SortMenuWidget extends ConsumerWidget {
  const SortMenuWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton(
      child: Row(
        children: [
          Text(
            'Sort',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.sort, color: Color(0xFF6C63FF)),
        ],
      ),

      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: 'Old to New',
            child: Text(
              'Old to New',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
          PopupMenuItem(
            value: 'New to Old',
            child: Text(
              'New to Old',
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
            ),
          ),
        ];
      },
      onSelected: (value) {
        ref.read(notesProvider.notifier).sortNotesByDate(value);
      },
    );
  }
}
