import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/widgets/custom_toast.dart';
import 'package:notes_app/widgets/option_bottom_sheet.dart';
import 'package:notes_app/widgets/save_pdf_helper.dart';
import '../datasource/notes_model.dart';
import '../provider/notes_provider.dart';
import '../screens/add_notes_screen.dart';

class NotesCard extends ConsumerWidget {
  final int index;
  final dynamic note;
  const NotesCard({super.key, required this.index, required this.note});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Hero(
      tag: index,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddNotesScreen(note: note),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20.0),
          child: Container(
            decoration: BoxDecoration(
              color: Color(int.parse(note.color!)),
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Color(int.parse(note.color!)).withAlpha(3),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          note.title ?? "Untitled Note",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      InkWell(
                        onTap: () => _showOptionsMenu(context, note, ref),

                        child: const Icon(Icons.more_vert),
                      ),
                    ],
                  ),

                  if (note.content != null)
                    Container(
                      constraints: const BoxConstraints(maxHeight: 120),
                      child: ClipRRect(
                        child: QuillEditor(
                          controller: QuillController(
                            readOnly: true,
                            document: Document.fromJson(
                              jsonDecode(note.content!),
                            ),
                            selection: const TextSelection.collapsed(offset: 0),
                          ),
                          scrollController: ScrollController(),
                          focusNode: FocusNode(),
                          config: const QuillEditorConfig(
                            padding: EdgeInsets.zero,
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
                        ? DateFormat('dd MMM  hh:mm a').format(note.date!)
                        : "",

                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(40),
                      borderRadius: BorderRadius.circular(12),
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
  }

  void _showOptionsMenu(BuildContext context, NotesModel note, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => OptionsBottomSheet(
            onShare: () {
              SavePdfHelper().sharePdf(note.title!, note.content!);
            },
            onDownload: () {
              SavePdfHelper().savePdf(note.title!, note.content!);
            },
            onDelete: () {
              ref.read(notesProvider.notifier).deleteNote(note);
              CustomToast.showSuccess("Deleted!", "Note deleted successfully.");
            },
          ),
    );
  }
}
