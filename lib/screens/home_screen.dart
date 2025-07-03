import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notes_app/provider/notes_provider.dart';
import 'package:notes_app/screens/add_notes_screen.dart';
import 'package:notes_app/widgets/ai_summarizer_bottom_sheet.dart';
import 'package:notes_app/widgets/empty_notes_widget.dart';
import 'package:notes_app/widgets/filter_menu_widget.dart';
import 'package:notes_app/widgets/notes_card.dart';
import 'package:notes_app/widgets/search_bar_widget.dart';
import 'package:notes_app/widgets/toggle_view_button.dart';
import 'package:notes_app/widgets/tools_options.dart';

import '../widgets/generate_notes_bottom_sheet.dart';

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
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade100,
        elevation: 0,
        toolbarHeight: 80,

        title: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notes',
                style: GoogleFonts.poppins(
                  color: Colors.black87,
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Consumer(
                builder: (context, ref, child) {
                  final count = ref.watch(notesProvider).length;
                  return Text(
                    "$count Note${count != 1 ? 's' : ''}",
                    style: GoogleFonts.poppins(
                      color: Colors.grey[600],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 16.0),
        child: Column(
          spacing: 16,
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
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

            Text(
              "Categories:",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.start,
            ),
            FilterMenuWidget(),

            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(
                "Tools:",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                spacing: 8,
                children: [
                  ToolsOptions(
                    iconData: Icons.psychology_outlined,
                    text: 'AI Summarizer',
                    onTap: () {
                      ref.read(generatedSummaryProvider.notifier).state = '';
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => const AiSummarizerBottomSheet(),
                      );
                    },
                  ),
                  ToolsOptions(
                    iconData: Icons.auto_awesome_outlined,
                    text: "Generate Notes",
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        useRootNavigator: true,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                        ),
                        builder: (context) => const GenerateNotesBottomSheet(),
                      );
                    },
                  ),
                ],
              ),
            ),

            Row(
              spacing: 12,
              children: [
                Text(
                  'View:',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),

                ToggleViewButton(
                  icon: Icons.grid_view_rounded,
                  isSelected: ref.watch(selectViewStateProvider) == 'Grid',
                  onTap:
                      () => ref
                          .read(selectViewStateProvider.notifier)
                          .update((state) => 'Grid'),
                ),

                ToggleViewButton(
                  icon: Icons.format_list_bulleted_rounded,
                  isSelected: ref.watch(selectViewStateProvider) == 'List',
                  onTap:
                      () => ref
                          .read(selectViewStateProvider.notifier)
                          .update((state) => 'List'),
                ),
              ],
            ),

            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final notes = ref.watch(notesProvider);
                  final viewMode = ref.watch(selectViewStateProvider);

                  if (notes.isEmpty) {
                    return const EmptyNotesWidget();
                  }

                  return viewMode == 'Grid'
                      ? MasonryGridView.count(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        itemCount: notes.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return FadeInUp(
                            duration: Duration(milliseconds: 300 + index * 100),
                            child: NotesCard(index: index, note: note),
                          );
                        },
                      )
                      : ListView.separated(
                        itemCount: notes.length,
                        separatorBuilder:
                            (context, _) => const SizedBox(height: 12),
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 20),
                        itemBuilder: (context, index) {
                          final note = notes[index];
                          return FadeInRight(
                            duration: Duration(milliseconds: 300 + index * 100),
                            child: NotesCard(index: index, note: note),
                          );
                        },
                      );
                },
              ),
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
