import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tasty_recipe/Screens/LoginScreen.dart';
import 'package:tasty_recipe/Screens/onboarding/OnboardingPage.dart';

class OnboardingScreen extends StatefulWidget {
  static const String route = "/onboarding";

  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() {
    return OnboardingScreenState();
  }
}

class OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final Size deviceSize = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(),
      body: Stack(
        children: <Widget>[
          // Scrollable onboarding
          PageView(
            controller: _controller,
            onPageChanged: (value) {
              setState(() {
                _currentIndex = value;
              });
            },
            children: <Widget>[
              OnBoardingPage(
                "content/animations/onboardingRecipesBook.json",
                "Welcome to TastyRecipe",
                "Create and cook delicious dishes. All in one place!",
                "Your next favorite recipe is waiting for you!",
                deviceSize,
              ),
              OnBoardingPage(
                "content/animations/onboardingIngredients.json",
                "Add Your Own Creations",
                "Save and prepare your recipes",
                "Keep all your culinary ideas organized and ready to go.",
                deviceSize,
              ),
              OnBoardingPage(
                "content/animations/onboardingCooking.json",
                "Cook and Enjoy!",
                "Follow your recipes step-by-step",
                "Add ingredients to your shopping list, and make every meal a masterpiece.",
                deviceSize,
              ),
            ],
          ),

          // Skip button
          Positioned(
            right: 10.0,
            top: 0.0,
            child: TextButton(
              onPressed: () {
                setState(() {
                  _currentIndex = 2;
                });
                _controller.jumpToPage(_currentIndex);
              },
              child: const Text("Skip"),
            ),
          ),

          // Page indicator
          Positioned(
            bottom: 20.0,
            left: 20.0,
            child: SmoothPageIndicator(
              controller: _controller, // PageController
              count: 3,
              effect: ExpandingDotsEffect(dotHeight: 6), // indicator effect
              onDotClicked: (index) {
                setState(() {
                  _currentIndex = index;
                });
                _controller.jumpToPage(_currentIndex);
              },
            ),
          ),
        ],
      ),
      // Next button
      floatingActionButton: FloatingActionButton(
        tooltip: "Next Page",
        onPressed: () {
          if (_currentIndex == 2) {
            Navigator.popAndPushNamed(context, LoginScreen.route);
          } else {
            setState(() {
              _currentIndex++;
            });
            _controller.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.linear,
            );
          }
        },
        child: const Icon(Icons.arrow_forward_ios_rounded),
      ),
    );
  }
}
