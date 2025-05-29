import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/datasource/notes_model.dart';
import 'dart:convert';

import '../widgets/option_bottom_sheet.dart';

class AddNotesScreen extends ConsumerStatefulWidget {
  final NotesModel? note;
  const AddNotesScreen({super.key, this.note});

  @override
  ConsumerState<AddNotesScreen> createState() => _AddNotesScreenState();
}

class _AddNotesScreenState extends ConsumerState<AddNotesScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.note != null) {
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
            onShare: () {},
            onDownload: () {},
            onDelete: () {
              ref.read(notesProvider.notifier).deleteNote(widget.note!);
              Navigator.pop(context);
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 400;

    return Scaffold(
      backgroundColor: Colors.grey.shade200,
      appBar: AppBar(
        title: Text(
          widget.note != null ? 'Edit Note' : 'New Note',
          style: GoogleFonts.poppins(
            color: Colors.white,
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
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (widget.note != null) ...[
            IconButton(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onPressed: () {
                _showOptionsMenu();
              },
            ),
          ],
          TextButton(
            onPressed: _saveNote,
            child: Text(
              widget.note != null ? 'Update' : 'Save',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),

      body: Padding(
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
            ),

            Row(
              children: [
                SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
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

                const Spacer(),

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
                          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
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
                                  .read(selectCategoryStateProvider.notifier)
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

            Expanded(
              child: Container(
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
                      expands: true,
                      padding: EdgeInsets.zero,
                      placeholder: "Start writing...",
                    ),
                  ),
                ),
              ),
            ),

            if (!isSmallScreen)
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
    );
  }
}
