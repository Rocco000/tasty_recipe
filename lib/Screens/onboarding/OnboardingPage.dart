import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class OnBoardingPage extends StatelessWidget {
  final String animation;
  final String title;
  final String subtitle;
  final String text;
  final Size deviceSize;

  const OnBoardingPage(
    this.animation,
    this.title,
    this.subtitle,
    this.text,
    this.deviceSize,
  );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Lottie.asset(
            animation,
            repeat: false,
            height: deviceSize.height * 0.5,
            width: deviceSize.width * 0.8,
          ),
          Text(title, style: Theme.of(context).textTheme.headlineLarge),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
