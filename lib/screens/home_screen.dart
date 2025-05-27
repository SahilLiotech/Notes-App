import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/datasource/notes_model.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/screens/add_notes_screen.dart';
import '../widgets/option_bottom_sheet.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final searchController = TextEditingController();

  final List<String> categories = [
    'Personal',
    'Work',
    'Ideas',
    'To-Do',
    'Other',
  ];

  final List<String> sort = ['Old to New', 'New to Old'];

  void _showOptionsMenu(NotesModel note) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => OptionsBottomSheet(
            onShare: () {},
            onExport: () {},
            onDelete: () {
              ref.read(notesProvider.notifier).deleteNote(note);
            },
          ),
    );
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
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search notes...',
                        hintStyle: GoogleFonts.poppins(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16.0,
                          horizontal: 16.0,
                        ),
                      ),
                      onChanged: (value) {
                        ref.read(notesProvider.notifier).searchNotes(value);
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(right: 8.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: PopupMenuButton(
                      icon: const Icon(
                        Icons.filter_list,
                        color: Color(0xFF6C63FF),
                      ),

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
                        ref
                            .read(notesProvider.notifier)
                            .filterNotes(selectedCategory);
                      },
                    ),
                  ),
                ],
              ),
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
                  PopupMenuButton(
                    icon: const Icon(Icons.sort, color: Color(0xFF6C63FF)),
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'Old to New',
                          child: Text(
                            'Old to New',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'New to Old',
                          child: Text(
                            'New to Old',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ];
                    },
                    onSelected: (value) {
                      ref.watch(notesProvider.notifier).sortNotesByDate(value);
                    },
                  ),
                ],
              ),
            ),

            Consumer(
              builder: (context, ref, child) {
                final notes = ref.watch(notesProvider);
                return Expanded(
                  child:
                      notes.isEmpty
                          ? Center(
                            child: Column(
                              spacing: 12,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.note_alt_outlined,
                                  size: 80,
                                  color: Colors.grey.shade300,
                                ),

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
                          )
                          : MasonryGridView.count(
                            crossAxisCount: 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemCount: notes.length,
                            physics: const BouncingScrollPhysics(),
                            itemBuilder: (context, index) {
                              final note = notes[index];
                              return Hero(
                                tag: index,
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder:
                                              (context) =>
                                                  AddNotesScreen(note: note),
                                        ),
                                      );
                                    },
                                    borderRadius: BorderRadius.circular(20.0),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Color(int.parse(note.color!)),
                                        borderRadius: BorderRadius.circular(
                                          20.0,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Color(
                                              int.parse(note.color!),
                                            ).withAlpha(3),
                                            spreadRadius: 1,
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(16.0),
                                        child: Column(
                                          spacing: 8,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Expanded(
                                                  child: Text(
                                                    note.title ??
                                                        "Untitled Note",
                                                    style: GoogleFonts.poppins(
                                                      fontSize: 18,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black,
                                                    ),
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap:
                                                      () => _showOptionsMenu(
                                                        note,
                                                      ),

                                                  child: const Icon(
                                                    Icons.more_vert,
                                                  ),
                                                ),
                                              ],
                                            ),

                                            if (note.content != null)
                                              Container(
                                                constraints:
                                                    const BoxConstraints(
                                                      maxHeight: 120,
                                                    ),
                                                child: ClipRRect(
                                                  child: QuillEditor(
                                                    controller: QuillController(
                                                      document:
                                                          Document.fromJson(
                                                            jsonDecode(
                                                              note.content!,
                                                            ),
                                                          ),
                                                      selection:
                                                          const TextSelection.collapsed(
                                                            offset: 0,
                                                          ),
                                                    ),
                                                    scrollController:
                                                        ScrollController(),
                                                    focusNode: FocusNode(),
                                                    config:
                                                        const QuillEditorConfig(
                                                          padding:
                                                              EdgeInsets.zero,
                                                          showCursor: false,
                                                          autoFocus: false,
                                                          expands: false,
                                                        ),
                                                  ),
                                                ),
                                              )
                                            else
                                              Text(
                                                "No content",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            const SizedBox(height: 8),
                                            Text(
                                              note.date != null
                                                  ? DateFormat(
                                                    'dd MMM  hh:mm a',
                                                  ).format(note.date!)
                                                  : "",

                                              style: GoogleFonts.poppins(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.black,
                                              ),
                                            ),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Colors.black.withAlpha(
                                                  40,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              child: Text(
                                                note.category ?? "No Category",
                                                style: GoogleFonts.poppins(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Colors.black,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
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
