import 'dart:async';
import 'package:flutter/material.dart';
import 'package:tasty_recipe/Models/Recipe.dart';
import 'package:tasty_recipe/Models/RecipeStep.dart';
import 'package:tasty_recipe/Widgets/RecipeStepWidget.dart';

class PrepareRecipeScreen extends StatefulWidget {
  static const String route = "/prepareRecipe";

  const PrepareRecipeScreen({super.key});

  @override
  State<PrepareRecipeScreen> createState() => _PrepareRecipeScreenState();
}

class _PrepareRecipeScreenState extends State<PrepareRecipeScreen>
    with SingleTickerProviderStateMixin {
  int _showedStep = 0;
  int _hours = 0, _minutes = 0, _seconds = 0;
  int _remainingSeconds = 0;

  Timer? _timer;
  bool _isRunning = false;
  late AnimationController _controller;

  final Recipe _recipe = Recipe(
    null,
    "1",
    "Chocolate cake",
    2,
    60,
    4,
    "Dessert",
    ["Lactose Free", "Vegan"],
    false,
    "",
  );

  final List<RecipeStep> _recipeSteps = [
    RecipeStep(
      "0",
      0,
      "1 bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh, svfdsgvfd . nuinibn ",
      2,
      "minute",
    ),
    RecipeStep(
      "1",
      1,
      "2 bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh, fsdg. fretge",
      0,
      "minute",
    ),
    RecipeStep(
      "2",
      2,
      "3 bacdfgrgt vfrgtrsghbt gvfrfagvfrae gvergh",
      50,
      "minute",
    ),
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(minutes: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _goToNextStep() {
    _timer?.cancel();
    _controller.reset();
    if (_showedStep < _recipeSteps.length - 1) {
      setState(() {
        _showedStep += 1;
        _remainingSeconds = 0;
        _isRunning = false;
      });
    }
  }

  void _startRecipeTimer(double duration, String unit) {
    setState(() {
      _remainingSeconds = (unit == "hour")
          ? (duration * 60 * 60).toInt()
          : (unit == "minute")
          ? (duration * 60).toInt()
          : duration.toInt();
      _isRunning = true;
      List<int> countdown = _computeTimerCountdown(_remainingSeconds);
      _hours = countdown[0];
      _minutes = countdown[1];
      _seconds = countdown[2];
    });

    _controller.duration = Duration(seconds: _remainingSeconds);
    _controller.forward(from: 0);

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _remainingSeconds -= 1;
        List<int> countdown = _computeTimerCountdown(_remainingSeconds);
        _hours = countdown[0];
        _minutes = countdown[1];
        _seconds = countdown[2];

        if (_remainingSeconds == 0) {
          _timer!.cancel();
          _isRunning = false;
          _controller.stop();

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text("Finish!"),
              backgroundColor: Colors.black45,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating, // Makes it float over the UI
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
    });
  }

  void _restartTimer() {
    _timer?.cancel();
    _controller.reset();
    setState(() {
      _remainingSeconds = 0;
    });
    _startRecipeTimer(_recipeSteps[_showedStep].duration!, "minute");
  }

  List<int> _computeTimerCountdown(int durationInSeconds) {
    if (durationInSeconds < 60) return [0, 0, durationInSeconds];

    double secondsInMinutes = durationInSeconds / 60;

    int minutes = secondsInMinutes.toInt();
    int seconds = ((secondsInMinutes - minutes) * 60).toInt();

    if (minutes < 60) return [0, minutes, seconds];

    double minutesInHours = minutes / 60;
    int hours = minutesInHours.toInt();
    minutes = ((minutesInHours - hours) * 60).toInt();

    return [hours, minutes, seconds];
  }

  Widget _generateRecipeStepCard(int index, bool lastStep) {
    return RecipeStepWidget(
      step: _recipeSteps[index],
      onPressedNextStep: (!lastStep) ? _goToNextStep : null,
      onPressedStartTimer: (_recipeSteps[index].duration != null)
          ? () => _startRecipeTimer(_recipeSteps[index].duration!, "minute")
          : null,
      lastStep: lastStep,
      showButtons: true,
      key: ValueKey<int>(_recipeSteps[index].stepOrder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.orange,
          foregroundColor: Colors.white,
          title: const Text("Tasty Recipe"),
        ),
        body: Column(
          spacing: 10,
          children: <Widget>[
            // RECIPE NAME
            const Text(
              "Let's prepare:",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              _recipe.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            // RECIPE STEPS
            AnimatedSwitcher(
              duration: Duration(milliseconds: 500),
              transitionBuilder: (child, animation) {
                return FadeTransition(
                  opacity: animation,
                  child: ScaleTransition(scale: animation, child: child),
                );
              },
              child: _generateRecipeStepCard(
                _showedStep,
                (_showedStep == _recipeSteps.length - 1),
              ),
            ),

            // TIMER
            if (_isRunning)
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.7,
                height: MediaQuery.of(context).size.width * 0.7,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 200,
                      height: 200,
                      child: Card(
                        color: Colors.white,
                        shadowColor: Colors.purple.shade300,
                        elevation: 10.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        clipBehavior: Clip.hardEdge,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: CircularProgressIndicator(
                            value: _controller.value,
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepPurple,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Text(
                      "${(_hours == 0)
                          ? "00"
                          : (_hours < 10)
                          ? "0$_hours"
                          : _hours} : ${(_minutes == 0)
                          ? "00"
                          : (_minutes < 10)
                          ? "0$_minutes"
                          : _minutes} : ${(_seconds == 0)
                          ? "00"
                          : (_seconds < 10)
                          ? "0$_seconds"
                          : _seconds}",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Padding(
                      padding: const EdgeInsets.only(top: 80),
                      child: CircleAvatar(
                        backgroundColor: Colors.purple.shade400,
                        child: IconButton(
                          color: Colors.white,
                          onPressed: () {
                            _restartTimer();
                          },
                          tooltip: "Restart timer",
                          icon: Icon(Icons.restore),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
