import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import '../provider/notes_provider.dart';

class FilterMenuWidget extends ConsumerWidget {
  const FilterMenuWidget({super.key});

  final List<String> categories = const [
    'All',
    'AI Generated',
    'Personal',
    'Work',
    'Ideas',
    'To-Do',
    'Other',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCategory = ref.watch(selectCategoryStateProvider);
    final primaryColor = const Color(0xFF6C63FF);

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children:
          categories.map((category) {
            final isSelected = selectedCategory == category;

            return GestureDetector(
              onTap: () {
                ref
                    .read(selectCategoryStateProvider.notifier)
                    .update((state) => category);
                ref.read(notesProvider.notifier).filterNotes(category);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : primaryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: Text(
                  category,
                  style: GoogleFonts.poppins(
                    color: isSelected ? Colors.white : primaryColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }
}
