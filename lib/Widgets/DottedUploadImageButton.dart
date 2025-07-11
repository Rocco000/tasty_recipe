import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tasty_recipe/Widgets/DottedButtonWidget.dart';

class DottedUploadImageButton extends StatelessWidget {
  final void Function() onTap;
  final File? image;

  const DottedUploadImageButton({required this.onTap, this.image, super.key});

  @override
  Widget build(BuildContext context) {
    return DottedButtonWidget(
      onTap: onTap,
      child:
          (image == null)
              ? Column(
                children: const <Widget>[
                  Icon(Icons.add_a_photo_rounded, color: Colors.blueAccent),
                  Text(
                    "Upload a photo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent,
                    ),
                  ),
                ],
              )
              : ClipRRect(
                borderRadius: BorderRadius.circular(4.0),
                clipBehavior: Clip.hardEdge,
                child: SizedBox.fromSize(
                  size: Size.square(250),
                  child: Image.file(image!, fit: BoxFit.cover),
                ),
              ),
    );
  }
}
