import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/widgets/custom_toast.dart';
import 'package:firebase_ai/firebase_ai.dart';

import '../provider/notes_provider.dart';
import '../datasource/notes_model.dart';

class AiSummarizerBottomSheet extends ConsumerStatefulWidget {
  const AiSummarizerBottomSheet({super.key});

  @override
  ConsumerState<AiSummarizerBottomSheet> createState() =>
      _AiSummarizerBottomSheetState();
}

class _AiSummarizerBottomSheetState
    extends ConsumerState<AiSummarizerBottomSheet> {
  final TextEditingController promptController = TextEditingController();
  NotesModel? selectedNote;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _generateNotes() async {
    if (selectedNote == null) {
      CustomToast.shoeFailed("Error", "Please select a note first.");
      return;
    }

    if (selectedNote!.content == null ||
        selectedNote!.content!.trim().isEmpty) {
      CustomToast.shoeFailed(
        "Error",
        "Selected note has no content to summarize.",
      );
      return;
    }

    ref.read(isGeneratingProvider.notifier).state = true;
    ref.read(generatedSummaryProvider.notifier).state = '';

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
        throw Exception('Could not initialize any AI model');
      }

      final prompt = '''
Please provide a concise summary of the following note content. 
Focus on the key points and main ideas. Keep it brief but comprehensive.

Note Title: ${selectedNote!.title ?? 'Untitled'}
Note Content: ${selectedNote!.content}

Please summarize this content in 2-3 sentences.
''';

      final result = await model.generateContent([Content.text(prompt)]);

      if (result.text != null && result.text!.isNotEmpty) {
        ref.read(generatedSummaryProvider.notifier).state = result.text!;
        CustomToast.showSuccess("Success", "Summary generated successfully!");
      } else {
        ref.read(generatedSummaryProvider.notifier).state =
            'No summary generated. Please try again.';
        CustomToast.shoeFailed(
          "Warning",
          "No summary was generated. Please try again.",
        );
      }
    } catch (e, stackTrace) {
      debugPrint('Error generating summary: $e');
      debugPrint('Stack trace: $stackTrace');

      String errorMessage = 'Failed to generate summary.';
      if (e.toString().contains('permission')) {
        errorMessage =
            'Permission denied. Please check your Firebase configuration.';
      } else if (e.toString().contains('network')) {
        errorMessage = 'Network error. Please check your internet connection.';
      } else if (e.toString().contains('quota')) {
        errorMessage = 'API quota exceeded. Please try again later.';
      }

      CustomToast.shoeFailed("Error", errorMessage);
      ref.read(generatedSummaryProvider.notifier).state =
          'Error: $errorMessage';
    } finally {
      ref.read(isGeneratingProvider.notifier).state = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 20,
            spreadRadius: 0,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width,
          child: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
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
                              Icons.psychology_outlined,
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
                                  'AI Summarizer',
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
                        child: Icon(
                          Icons.close,
                          color: Colors.grey.shade600,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                Text(
                  "Select a note to generate a concise summary, AI-Powered summary",
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                Text(
                  'Choose a note to summarize',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 12),

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade500, width: 1),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final notes = ref.watch(notesProvider);
                        return DropdownButton(
                          borderRadius: BorderRadius.circular(16),
                          padding: const EdgeInsets.all(8),
                          isExpanded: true,
                          underline: const SizedBox(),
                          hint: const Text(
                            'Select a note',
                            style: TextStyle(color: Colors.grey),
                          ),
                          value: selectedNote,
                          items:
                              notes.isNotEmpty
                                  ? notes.map((note) {
                                    return DropdownMenuItem(
                                      value: note,

                                      child: Text(
                                        note.title ?? 'No Title',
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          color: Colors.grey.shade800,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                  : [
                                    DropdownMenuItem(
                                      child: Text('No notes available'),
                                    ),
                                  ],
                          onChanged: (value) {
                            setState(() {
                              selectedNote = value as NotesModel?;
                            });
                          },
                        );
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                Consumer(
                  builder: (context, ref, child) {
                    final isGenerating = ref.watch(isGeneratingProvider);
                    final generatedSummary = ref.watch(
                      generatedSummaryProvider,
                    );

                    return Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton(
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
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
                                          ),
                                        ),
                                      ],
                                    )
                                    : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        const Icon(
                                          Icons.psychology_outlined,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Generate Summary',
                                          style: GoogleFonts.poppins(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                          ),
                        ),

                        if (generatedSummary.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: Colors.grey.shade300),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.grey.shade200,
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.summarize,
                                      color: const Color(0xFF6C63FF),
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Generated Summary',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.grey.shade900,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {
                                        Clipboard.setData(
                                          ClipboardData(text: generatedSummary),
                                        ).then((_) {
                                          CustomToast.showSuccess(
                                            "Copied",
                                            "Summary copied to clipboard!",
                                          );
                                        });
                                      },
                                      icon: Icon(
                                        Icons.copy,
                                        color: Colors.grey.shade600,
                                        size: 20,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  generatedSummary,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                Center(
                  child: Text(
                    'AI-generated content may not always be accurate',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.black45,
                    ),
                  ),
                ),

                SizedBox(height: MediaQuery.of(context).viewInsets.bottom),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
