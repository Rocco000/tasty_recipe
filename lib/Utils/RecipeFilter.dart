enum RecipeFilterType {
  favorites,
  breakfast,
  firstCourse,
  secondCourse,
  snack,
  dessert
}

class RecipeFilter{
  final RecipeFilterType type;

  RecipeFilter.favorites() : type = RecipeFilterType.favorites;

  RecipeFilter.breakfast() : type = RecipeFilterType.breakfast;

  RecipeFilter.firstCourse() : type = RecipeFilterType.firstCourse;

  RecipeFilter.secondCourse() : type = RecipeFilterType.secondCourse;

  RecipeFilter.snack() : type = RecipeFilterType.snack;

  RecipeFilter.dessert() : type = RecipeFilterType.dessert;

}