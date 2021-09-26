import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:rich_text_view/src/models.dart';

part 'suggestion_state.dart';

class SuggestionCubit extends Cubit<SuggestionState> {
  final double itemHeight;

  SuggestionCubit(this.itemHeight) : super(SuggestionState());

  set suggestions(List<Suggestion> value) {
    emit(state.copyWith(suggestions: value));
  }

  set hashtags(List<HashTag> value) {
    emit(state.copyWith(hashtags: value));
  }

  void onChanged(
      String? value,
      List<HashTag>? initialTags,
      List<Suggestion>? initialMentions,
      Future<List<HashTag>> Function(String)? onSearchTags,
      Future<List<Suggestion>> Function(String)? onSearchPeople) async {
    var last = value ?? '';
    emit(state.copyWith(last: last));
    var isHash = last.startsWith('#');
    var isMention = last.startsWith('@');
    if (last.isNotEmpty && (isHash || isMention)) {
      if (last.length == 1) {
        clear(hash: isMention ? null : initialTags, people: isHash ? null : initialMentions);
      } else if (isMention) {
        var temp = onSearchPeople != null && last.length > 1
            ? await onSearchPeople(last.split('@')[1])
            : initialMentions?.where((e) => e.subtitle.contains(last)).toList();
        clear(
          people: temp ?? [],
        );
      } else if (isHash) {
        await Future.delayed(Duration(milliseconds: 500));
        var temp = onSearchTags != null
            ? await onSearchTags(last)
            : initialTags?.where((e) => e.hashtag.contains(last)).toList();
        clear(
          hash: temp,
        );
      }
    } else {
      clear();
    }
    emit(state.copyWith(last: value));
  }

  set suggestionHeight(double value) {
    emit(state.copyWith(suggestionHeight: value));
  }

  set loading(bool value) {
    emit(state.copyWith(loading: value));
  }

  TextEditingController onUserSelect(String item, TextEditingController controller) {
    var lines = controller.text.split('\n');
    var words = lines.last.split(' ');
    words.last = item;
    var lastLine = words.join(' ');
    lines.removeLast();
    lines.add(lastLine);
    controller.value = TextEditingValue(
      text: lines.join('\n'),
      selection: TextSelection.fromPosition(TextPosition(offset: controller.text.length)),
    );

    suggestionHeight = 1;
    hashtags = [];
    suggestions = [];
    return controller;
  }

  void clear({List<HashTag>? hash, List<Suggestion>? people, bool load = false}) {
    loading = load;
    suggestions = people ?? [];
    hashtags = hash ?? [];
    suggestionHeight = load
        ? 150.0
        : people != null
            ? (itemHeight * people.length).clamp(1.0, 280.0)
            : hash != null
                ? (itemHeight * hash.length).clamp(1.0, 280.0)
                : 1.0;
  }
}
