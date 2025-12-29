import 'package:flutter/material.dart';

class TagFilterChips extends StatelessWidget {
  final List<String> tags;
  final String selectedTag;
  final ValueChanged<String> onTagSelected;

  const TagFilterChips({
    super.key,
    required this.tags,
    required this.selectedTag,
    required this.onTagSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: tags.map((tag) {
          final isSelected = selectedTag == tag;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(tag),
              selected: isSelected,
              onSelected: (_) {
                onTagSelected(tag);
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
