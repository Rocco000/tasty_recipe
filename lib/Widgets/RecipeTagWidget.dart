import 'package:flutter/material.dart';

class RecipeTagWidget extends StatelessWidget {
  final String text;
  final Widget trailing;
  final void Function(bool) onSelectionFunction;
  final bool isSelected;

  const RecipeTagWidget({
    required this.text,
    required this.isSelected,
    required this.trailing,
    required this.onSelectionFunction,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(text),
          Padding(padding: const EdgeInsets.only(left: 8.0), child: trailing),
        ],
      ),
      selected: isSelected,
      onSelected: (selection) {
        onSelectionFunction(selection);
      },
      checkmarkColor: Colors.green,
      selectedColor: Colors.green.shade100,
    );
  }
}
