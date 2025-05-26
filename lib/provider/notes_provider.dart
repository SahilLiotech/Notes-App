import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:notes_app/datasource/notes_model.dart';

final selectColorStateProvider = StateProvider<Color>((ref) => Colors.white);

final selectCategoryStateProvider = StateProvider<String>((ref) => 'Personal');

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

  void deleteNote(int index) {
    notesBox.deleteAt(index);
    state = notesBox.values.toList();
  }

  void updateNote(int index, NotesModel note) {
    notesBox.putAt(index, note);
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
    if (category.isEmpty) {
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
    if (order == 'oldToNew') {
      state.sort((a, b) => a.date!.compareTo(b.date!));
    } else if (order == 'newToOld') {
      state.sort((a, b) => b.date!.compareTo(a.date!));
    }
    state.sort((a, b) => b.date!.compareTo(a.date!));
  }
}
