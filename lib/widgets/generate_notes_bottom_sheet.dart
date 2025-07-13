import 'package:firebase_ai/firebase_ai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/widgets/custom_toast.dart';

import '../datasource/notes_model.dart';

class GenerateNotesBottomSheet extends ConsumerStatefulWidget {
  const GenerateNotesBottomSheet({super.key});

  @override
  ConsumerState<GenerateNotesBottomSheet> createState() =>
      _GenerateNotesBottomSheetState();
}

class _GenerateNotesBottomSheetState
    extends ConsumerState<GenerateNotesBottomSheet> {
  final TextEditingController promptController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    promptController.dispose();
    super.dispose();
  }

  void _generateNotes() async {
    final prompt = promptController.text.trim();
    if (prompt.isEmpty) {
      CustomToast.shoeFailed("Error", "Please enter a prompt.");
      return;
    }
    ref.read(isGeneratingProvider.notifier).state = true;

    try {
      final modelNames = ['gemini-2.5-flash', 'gemini-1.5-flash', 'gemini-pro'];
      GenerativeModel? model;

      for (final modelName in modelNames) {
        try {
          model = FirebaseAI.googleAI().generativeModel(model: modelName);
          break;
        } catch (e) {
          debugPrint('Failed to create model $modelName: $e');
          continue;
        }
      }

      if (model == null) {
        CustomToast.shoeFailed(
          "Error",
          "No available AI model found. Please try again later.",
        );
        return;
      }

      final result = await model.generateContent([Content.text(prompt)]);

      ref.read(isGeneratingProvider.notifier).state = false;
      if (result.text == null || result.text!.isEmpty) {
        CustomToast.shoeFailed(
          "Error",
          "AI did not return any content. Please try a different prompt.",
        );
      } else {
        ref.read(generatedNotesContectProvider.notifier).state = result.text!;
        ref.read(showPreviewProvider.notifier).state = true;
        CustomToast.showSuccess("Success", "Notes generated successfully.");
        debugPrint('Generated Notes: ${result.text}');
      }
    } catch (e, stack) {
      debugPrint('Error generating notes: $e \n StackTrace: $stack');
      CustomToast.shoeFailed(
        "Error",
        "Failed to generate notes. Please try again.",
      );
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }

  void _saveNote() {
    final generatedContent = ref.read(generatedNotesContectProvider);
    if (generatedContent.trim().isNotEmpty) {
      ref
          .read(notesProvider.notifier)
          .addNote(
            NotesModel(
              title: promptController.text.trim(),
              content: generatedContent,
              color: Colors.white.toARGB32().toString(),
              category: "AI Generated",
              date: DateTime.now(),
            ),
          );
      CustomToast.showSuccess("Success", "Note saved successfully.");
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final showPreview = ref.watch(showPreviewProvider.select((value) => value));
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 0,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: showPreview ? _buildPreviewContent() : _buildPromptContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildPromptContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8B7EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withAlpha(39),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Note Generator',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          'Powered by AI',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        Text(
          "Transform your ideas into comprehensive, well-structured notes instantly",
          style: GoogleFonts.poppins(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 32),

        Text(
          'What would you like notes about?',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 12),

        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: TextField(
            controller: promptController,
            maxLines: 8,
            style: GoogleFonts.poppins(fontSize: 14, height: 1.5),
            decoration: InputDecoration(
              hintText:
                  'e.g., "Create detailed notes about photosynthesis for biology class" or "Summarize the key concepts of machine learning"',
              hintStyle: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.grey.shade500,
                height: 1.5,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: Colors.black),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(
                  color: Color(0xFF6C63FF),
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.all(20),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'Quick Prompts',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _buildQuickPrompt('Physics concepts'),
            _buildQuickPrompt('History timeline'),
            _buildQuickPrompt('Programming basics'),
            _buildQuickPrompt('Literature analysis'),
          ],
        ),
        const SizedBox(height: 32),

        SizedBox(
          width: double.infinity,
          height: 54,
          child: Consumer(
            builder: (context, ref, child) {
              final isGenerating = ref.watch(isGeneratingProvider);
              return ElevatedButton(
                onPressed: isGenerating ? null : _generateNotes,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C63FF),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  disabledBackgroundColor: Colors.grey.shade300,
                ),
                child:
                    isGenerating
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'Generating...',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                        : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.auto_awesome, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              'Generate Notes',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Text(
            'AI-generated content may not always be accurate',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  Widget _buildPreviewContent() {
    final generatedContent = ref.watch(generatedNotesContectProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade500,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6C63FF), Color(0xFF8B7EFF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6C63FF).withAlpha(39),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'AI Note Generator',
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade900,
                          ),
                        ),
                        Text(
                          'Powered by AI',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6C63FF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                Navigator.pop(context);
              },
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.close, color: Colors.grey.shade600, size: 20),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        Text(
          'Generated Note Preview',
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade900,
          ),
        ),
        const SizedBox(height: 16),

        Container(
          width: double.infinity,
          constraints: const BoxConstraints(maxHeight: 400),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: MarkdownBody(
              data: generatedContent,
              styleSheet: MarkdownStyleSheet.fromTheme(
                Theme.of(context),
              ).copyWith(
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
                p: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
                code: GoogleFonts.robotoMono(
                  fontSize: 13,
                  color: Colors.deepPurple,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 54,
                child: Consumer(
                  builder: (context, ref, child) {
                    return OutlinedButton(
                      onPressed: () {
                        ref.read(showPreviewProvider.notifier).state = false;
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFF6C63FF)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        'Edit Prompt',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6C63FF),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: _saveNote,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Save Note',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Center(
          child: Text(
            'AI-generated content may not always be accurate',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.black45),
          ),
        ),

        SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
      ],
    );
  }

  Widget _buildQuickPrompt(String text) {
    return GestureDetector(
      onTap: () {
        promptController.text = 'Create detailed notes about $text';
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF6C63FF).withAlpha(26),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF6C63FF).withAlpha(39)),
        ),
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF6C63FF),
          ),
        ),
      ),
    );
  }
}
