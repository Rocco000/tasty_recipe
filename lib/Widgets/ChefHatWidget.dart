import 'package:flutter/material.dart';

class ChefHatWidget extends StatelessWidget {
  final void Function(int position) onPressed;
  final int chefHat;

  const ChefHatWidget({required this.onPressed, this.chefHat = 0, super.key});

  Widget generateIcon(int pos) {
    if (pos <= chefHat) {
      return Image.asset(
        "content/images/chefHat.png",
        color: Colors.amber[700],
        width: 30,
        height: 30,
      );
    } else {
      return Image.asset(
        "content/images/chefHat.png",
        color: Colors.grey,
        width: 30,
        height: 30,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return InkWell(
          onTap: () {
            onPressed(index);
          },
          child: generateIcon(index),
        );
      }),
    );
  }
}
