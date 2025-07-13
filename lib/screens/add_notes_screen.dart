import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/datasource/notes_model.dart';
import 'dart:convert';

import '../widgets/option_bottom_sheet.dart';
import '../widgets/save_pdf_helper.dart';

class AddNotesScreen extends ConsumerStatefulWidget {
  final NotesModel? note;
  const AddNotesScreen({super.key, this.note});

  @override
  ConsumerState<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends ConsumerState<AddNotesScreen> {
  bool get isAiNote => widget.note?.category == "AI Generated";

  @override
  void initState() {
    super.initState();
    if (widget.note != null && !isAiNote) {
      _titleController.text = widget.note!.title ?? '';
      _controller.document = Document.fromJson(
        jsonDecode(widget.note!.content ?? '{}'),
      );
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectColorStateProvider.notifier)
            .update(
              (state) => Color(int.parse(widget.note!.color ?? '0xFFFFFFFF')),
            );
        ref
            .read(selectCategoryStateProvider.notifier)
            .update((state) => widget.note!.category ?? 'Personal');
      });
    } else if (widget.note != null && isAiNote) {
      _titleController.text = widget.note!.title ?? '';
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectColorStateProvider.notifier)
            .update(
              (state) => Color(int.parse(widget.note!.color ?? '0xFFFFFFFF')),
            );
        ref
            .read(selectCategoryStateProvider.notifier)
            .update((state) => widget.note!.category ?? 'AI Generated');
      });
    }
  }

  final QuillController _controller = QuillController.basic();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _contentFocusNode = FocusNode();
  final TextEditingController _titleController = TextEditingController();

  final List<Color> cardColors = [
    Colors.white,
    Colors.yellow.shade200,
    Colors.green.shade200,
    Colors.blue.shade200,
    Colors.pink.shade200,
    Colors.orange.shade200,
    Colors.purple.shade200,
  ];

  final List<String> categories = [
    'Personal',
    'AI Generated',
    'Work',
    'Ideas',
    'To-Do',
    'Other',
  ];

  @override
  void dispose() {
    _titleFocusNode.dispose();
    _contentFocusNode.dispose();
    _titleController.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _saveNote() {
    final title = _titleController.text.trim();
    final content = jsonEncode(_controller.document.toDelta().toJson());

    if (title.isEmpty || content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Title and content cannot be empty'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final note = NotesModel(
      title: title,
      content: content,
      date: widget.note != null ? widget.note!.date : DateTime.now(),
      color: ref.watch(selectColorStateProvider).toARGB32().toString(),
      category: ref.read(selectCategoryStateProvider),
    );

    widget.note != null
        ? ref.read(notesProvider.notifier).updateNote(widget.note!.key!, note)
        : ref.read(notesProvider.notifier).addNote(note);
    Navigator.pop(context);
  }

  void _showOptionsMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder:
          (context) => OptionsBottomSheet(
            onShare: () {
              SavePdfHelper().sharePdf(
                widget.note!.title!,
                widget.note!.content!,
              );
            },
            onDownload: () {
              SavePdfHelper().savePdf(
                widget.note!.title!,
                widget.note!.content!,
              );
            },
            onDelete: () {
              ref.read(notesProvider.notifier).deleteNote(widget.note!);
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        toolbarHeight: 80,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(
            spacing: 4,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Column(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      widget.note != null ? 'Edit Note' : 'New Note',
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      widget.note != null
                          ? 'Last edited: ${DateFormat('dd/MM/yyy HH:mm').format(widget.note!.date!)}'
                          : 'Creating a new note',
                      style: GoogleFonts.poppins(
                        color: Colors.grey[600],
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.note != null)
                IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black),
                  onPressed: _showOptionsMenu,
                ),
              TextButton(
                onPressed: _saveNote,
                child: Text(
                  widget.note != null ? 'Update' : 'Save',
                  style: GoogleFonts.poppins(
                    color: const Color(0xFF6C63FF),
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            spacing: 24,
            children: [
              TextField(
                controller: _titleController,
                focusNode: _titleFocusNode,
                style: GoogleFonts.poppins(fontSize: 20),
                decoration: InputDecoration(
                  hintText: 'Title',
                  hintStyle: GoogleFonts.poppins(color: Colors.grey),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.black, width: 1),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                ),
                readOnly: isAiNote, // Make title read-only for AI notes
              ),

              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    SizedBox(
                      height: 40,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: cardColors.length,
                        itemBuilder: (context, index) {
                          final color = cardColors[index];
                          return Consumer(
                            builder: (context, ref, child) {
                              final selectedColor = ref.watch(
                                selectColorStateProvider,
                              );
                              return GestureDetector(
                                onTap:
                                    () => ref
                                        .read(selectColorStateProvider.notifier)
                                        .update((state) => color),
                                child: Container(
                                  margin: const EdgeInsets.only(right: 8),
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          selectedColor == color
                                              ? Colors.black
                                              : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),

                    Consumer(
                      builder: (context, ref, watch) {
                        final selectedCategory = ref.watch(
                          selectCategoryStateProvider,
                        );
                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            color: Colors.grey.shade400,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCategory,
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                              icon: const Icon(
                                Icons.keyboard_arrow_down,
                                size: 20,
                              ),
                              items:
                                  categories
                                      .map(
                                        (cat) => DropdownMenuItem(
                                          value: cat,
                                          child: Text(cat),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  ref
                                      .read(
                                        selectCategoryStateProvider.notifier,
                                      )
                                      .update((state) => value);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),

              isAiNote && widget.note != null
                  ? Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: SingleChildScrollView(
                        child: MarkdownBody(
                          data: widget.note!.content ?? '',
                          styleSheet: MarkdownStyleSheet.fromTheme(
                            Theme.of(context),
                          ).copyWith(
                            p: GoogleFonts.poppins(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            h1: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                            h2: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            h3: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            code: GoogleFonts.robotoMono(
                              fontSize: 13,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                  )
                  : Container(
                    height: MediaQuery.of(context).size.height * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      border: Border.all(color: Colors.grey, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: QuillEditor(
                        controller: _controller,
                        scrollController: ScrollController(),
                        focusNode: _contentFocusNode,
                        config: QuillEditorConfig(
                          scrollable: true,
                          expands: true,
                          padding: EdgeInsets.zero,
                          placeholder: "Start writing...",
                        ),
                      ),
                    ),
                  ),

              if (!isAiNote)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: QuillSimpleToolbar(
                    controller: _controller,
                    config: QuillSimpleToolbarConfig(
                      color: Colors.grey.shade200,
                      showAlignmentButtons: true,
                      showBackgroundColorButton: false,
                      showCenterAlignment: true,
                      showColorButton: false,
                      showCodeBlock: false,
                      showDirection: false,
                      showFontFamily: false,
                      showDividers: false,
                      showIndent: false,
                      showInlineCode: false,
                      showJustifyAlignment: false,
                      showLeftAlignment: true,
                      showLink: false,
                      showListNumbers: true,
                      showListBullets: true,
                      showListCheck: true,
                      showQuote: true,
                      showRightAlignment: true,
                      showSearchButton: false,
                      showSmallButton: false,
                      showHeaderStyle: true,
                      showUnderLineButton: true,
                      showStrikeThrough: true,
                      showSubscript: false,
                      showSuperscript: false,
                      multiRowsDisplay: false,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
