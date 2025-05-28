import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/notes_provider.dart';

class FilterMenuWidget extends ConsumerWidget {
  const FilterMenuWidget({super.key});

  final List<String> categories = const [
    'All',
    'Personal',
    'Work',
    'Ideas',
    'To-Do',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(right: 8.0),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12.0)),
      child: PopupMenuButton(
        icon: const Icon(Icons.filter_list, color: Color(0xFF6C63FF)),
        itemBuilder: (context) {
          return [
            PopupMenuItem(
              enabled: false,
              value: 'All',
              child: Text(
                'Filter By Categories',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            ...categories.map((category) {
              return PopupMenuItem(
                value: category,
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black87,
                  ),
                ),
              );
            }),
          ];
        },
        onSelected: (value) {
          final selectedCategory = value;
          ref.read(notesProvider.notifier).filterNotes(selectedCategory);
        },
      ),
    );
  }
}
