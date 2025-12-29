import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:tasty_recipe/recipe/models/entities/Ingredient.dart';
import 'package:tasty_recipe/recipe/models/entities/Recipe.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeIngredient.dart';
import 'package:tasty_recipe/recipe/models/entities/RecipeStep.dart';
import 'package:tasty_recipe/recipe/createRecipe/AddRecipeIngredientsScreen.dart';
import 'package:tasty_recipe/recipe/createRecipe/AddRecipeStepsScreen.dart';
import 'package:tasty_recipe/cart/CartScreen.dart';
import 'package:tasty_recipe/recipe/createRecipe/CreateRecipeScreen.dart';
import 'package:tasty_recipe/recipe/editRecipe/EditIngredientsScreen.dart';
import 'package:tasty_recipe/recipe/editRecipe/EditRecipeScreen.dart';
import 'package:tasty_recipe/recipe/editRecipe/EditRecipeStepsScreen.dart';
import 'package:tasty_recipe/Screens/HomeScreen.dart';
import 'package:tasty_recipe/recipe/prepareRecipe/PrepareRecipeScreen.dart';
import 'package:tasty_recipe/Screens/ProfileScreen.dart';
import 'package:tasty_recipe/recipe/viewRecipe/RecipeDetailsScreen.dart';
import 'package:tasty_recipe/recipe/browseRecipe/RecipeListScreen.dart';
import 'package:tasty_recipe/user/authentication/ForgotPasswordScreen.dart';
import 'package:tasty_recipe/user/authentication/LoginScreen.dart';
import 'package:tasty_recipe/Screens/onboarding/OnboardingScreen.dart';
import 'package:tasty_recipe/user/authentication/AccountCreatedScreen.dart';
import 'package:tasty_recipe/user/authentication/SingUpScreen.dart';
import 'package:tasty_recipe/user/authentication/VerifyEmailScreen.dart';
import 'package:tasty_recipe/cart/CartController.dart';
import 'package:tasty_recipe/recipe/createRecipe/RecipeCreationController.dart';
import 'package:tasty_recipe/recipe/viewRecipe/RecipeDetailsController.dart';
import 'package:tasty_recipe/recipe/browseRecipe/RecipeListController.dart';
import 'package:tasty_recipe/recipe/editRecipe/RecipeEditFlow.dart';
import 'package:tasty_recipe/Utils/auth.dart';

class MyRouter {
  final Auth _authService;

  late final GoRouter routes;

  MyRouter(this._authService) {
    routes = GoRouter(
      redirect: (context, state) {
        // Authentication Guard
        final isLogged = _authService.currentUser;
        final bool isLoginRoute = state.path! == LoginScreen.route;

        if (isLogged == null) {
          return LoginScreen.route;
        } else if (isLogged != null && isLoginRoute) {
          return HomeScreen.route;
        }
      },
      routes: [
        // Home Screen
        GoRoute(
          path: HomeScreen.route,
          builder: (context, state) => HomeScreen(),
        ),

        // Onboarding Screen
        GoRoute(
          path: OnboardingScreen.route,
          builder: (context, state) => OnboardingScreen(),
        ),

        // Login
        GoRoute(
          path: LoginScreen.route,
          builder: (context, state) => LoginScreen(),
          routes: [
            // Forgot password
            GoRoute(
              path: ForgotPasswordScreen.route,
              builder: (context, state) => ForgotPasswordScreen(),
            ),
          ],
        ),

        // SignUp
        GoRoute(
          path: SignUpScreen.route,
          builder: (context, state) => SignUpScreen(),
          routes: [
            // Verify Email screen
            GoRoute(
              path: VerifyEmailScreen.route,
              builder: (context, state) => VerifyEmailScreen(),
            ),
            // Account Created Success Screen
            GoRoute(
              path: AccounCreatedScreen.route,
              builder: (context, state) => AccounCreatedScreen(),
            ),
          ],
        ),

        // Profile Screen
        GoRoute(
          path: ProfileScreen.route,
          builder: (context, state) => ProfileScreen(),
        ),

        // Recipe Creation Flow
        ShellRoute(
          builder: (context, state, child) {
            print("Builder function CREATE FLOW");
            return ChangeNotifierProvider(
              create: (context) {
                print("!!! ESEGUITO CREATE CHANGE-NOTIFIER !!!");
                return RecipeCreationController();
              },
              child: child,
            );
          },
          routes: [
            // 1 - Add Recipe General Info
            GoRoute(
              path: CreateRecipeScreen.route,
              builder: (context, state) => CreateRecipeScreen(),
            ),
            // 2 - Add Recipe Ingredients
            GoRoute(
              path: AddRecipeIngredientsScreen.route,
              builder: (context, state) => AddRecipeIngredientsScreen(),
            ),
            // 3 - Add Recipe Steps
            GoRoute(
              path: AddRecipeStepsScreen.route,
              builder: (context, state) => AddRecipeStepsScreen(),
            ),
          ],
        ),

        // Recipe Details Screen
        GoRoute(
          path: RecipeDetailsScreen.route,
          builder: (context, state) {
            final recipe = state.extra as Recipe;
            return RecipeDetailsScreen(RecipeDetailsController(recipe));
          },
        ),

        // Recipe Edit Flow
        ShellRoute(
          builder: (context, state, child) {
            final args = state.extra as Map<String, dynamic>?;
            Recipe? recipe;
            List<RecipeIngredient> recipeIngredientList = [];
            List<Ingredient> ingredientList = [];
            List<RecipeStep> stepList = [];

            if (args != null) {
              recipe = args["recipe"] as Recipe;
              recipeIngredientList =
                  args["recipeIngredients"] as List<RecipeIngredient>;
              ingredientList = args["ingredients"] as List<Ingredient>;
              stepList = args["steps"] as List<RecipeStep>;
            }

            return RecipeEditFlow(
              recipe: recipe,
              recipeIngredientList: recipeIngredientList,
              ingredientList: ingredientList,
              stepList: stepList,
              child: child,
            );
          },
          routes: [
            // 1 - Edit Recipe General Info
            GoRoute(
              path: EditRecipeScreen.route,
              builder: (context, state) => EditRecipeScreen(),
            ),

            // 2 - Edit Recipe Ingredients
            GoRoute(
              path: EditIngredientsScreen.route,
              builder: (context, state) => EditIngredientsScreen(),
            ),

            // 3 - Edit Recipe Steps
            GoRoute(
              path: EditRecipeStepsScreen.route,
              builder: (context, state) => EditRecipeStepsScreen(),
            ),
          ],
        ),

        // Recipe List Screen
        GoRoute(
          path: RecipeListScreen.route,
          builder: (context, state) {
            // Get controller from state
            final controller = state.extra as RecipeListController;
            return RecipeListScreen(controller: controller);
          },
        ),

        // Cart Screen
        GoRoute(
          path: CartScreen.route,
          builder: (context, state) => CartScreen(CartController()),
        ),
      ],
    );
  }
}
