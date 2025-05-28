import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/screens/add_notes_screen.dart';
import 'package:notes_app/widgets/empty_notes_widget.dart';
import 'package:notes_app/widgets/notes_card.dart';
import 'package:notes_app/widgets/search_bar_widget.dart';
import 'package:notes_app/widgets/sort_menu_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Notes',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.0),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withAlpha(25),
                    spreadRadius: 1,
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: SearchBarWidget(controller: searchController),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Your Notes',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SortMenuWidget(),
                ],
              ),
            ),

            Consumer(
              builder: (context, ref, child) {
                final notes = ref.watch(notesProvider);
                return Expanded(
                  child:
                      notes.isEmpty
                          ? EmptyNotesWidget()
                          : MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemCount: notes.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return NotesCard(index: index, note: note);
                            },
                          ),
                );
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddNotesScreen()),
          );
        },
        backgroundColor: const Color(0xFF6C63FF),
        elevation: 4,
        label: Row(
          spacing: 8,
          children: [
            const Icon(Icons.add, color: Colors.white),

            Text(
              'New Note',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
