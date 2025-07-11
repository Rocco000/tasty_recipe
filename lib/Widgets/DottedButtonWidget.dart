import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/material.dart';

class DottedButtonWidget extends StatelessWidget {
  final void Function() onTap;
  final Widget? child;

  const DottedButtonWidget({required this.onTap, this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: DottedBorder(
        options: RoundedRectDottedBorderOptions(
          radius: Radius.circular(4.0),
          color: Colors.blueAccent,
          // To define the dash width and space between dashes
          dashPattern: [10, 5],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Center(child: child),
        ),
      ),
    );
  }
}
