import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/datasource/notes_model.dart';

final selectColorStateProvider = StateProvider<Color>((ref) => Colors.white);

final selectCategoryStateProvider = StateProvider<String>((ref) => 'Personal');

final selectViewStateProvider = StateProvider<String>((ref) => 'Grid');

final isGeneratingProvider = StateProvider<bool>((ref) => false);

final generatedSummaryProvider = StateProvider<String>((ref) => '');

final generatedNoteProvider = StateProvider<String>((ref) => '');

final generatedNotesContectProvider = StateProvider<String>((ref) => '');

final showPreviewProvider = StateProvider<bool>((ref) => false);

final notesProvider = NotifierProvider<NotesState, List<NotesModel>>(
  () => NotesState(),
);

class NotesState extends Notifier<List<NotesModel>> {
  late Box<NotesModel> notesBox;
  @override
  List<NotesModel> build() {
    notesBox = Hive.box<NotesModel>('notes');
    return notesBox.values.toList();
  }

  void addNote(NotesModel note) {
    notesBox.add(note);
    state = notesBox.values.toList();
  }

  void deleteNote(NotesModel note) {
    notesBox.delete(note.key);
    state = notesBox.values.toList();
  }

  void updateNote(int key, NotesModel note) {
    notesBox.put(key, note);
    state = notesBox.values.toList();
  }

  void searchNotes(String query) {
    if (query.isEmpty) {
      state = notesBox.values.toList();
    } else {
      state =
          notesBox.values
              .where(
                (note) =>
                    note.title!.toLowerCase().contains(query.toLowerCase()),
              )
              .toList();
    }
  }

  void filterNotes(String category) {
    if (category.isEmpty || category == 'All') {
      state = notesBox.values.toList();
    } else {
      state =
          notesBox.values
              .where(
                (notes) => notes.category!.toLowerCase().contains(
                  category.toLowerCase(),
                ),
              )
              .toList();
    }
  }

  void sortNotesByDate(String order) {
    final sortedNotes = [...state];
    if (order == 'Old to New') {
      sortedNotes.sort((a, b) => a.date!.compareTo(b.date!));
    } else {
      sortedNotes.sort((a, b) => b.date!.compareTo(a.date!));
    }
    state = sortedNotes;
  }
}
