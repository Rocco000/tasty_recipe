import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:tasty_recipe/Models/Ingredient.dart';
import 'package:tasty_recipe/Models/RecipeIngredient.dart';

class IngredientFormField extends StatelessWidget {
  final int ingredientNumber;
  final List<Ingredient> ingredientList;
  final String? ingredientName;
  final RecipeIngredient? recipeIngredient;

  const IngredientFormField({
    required this.ingredientNumber,
    required this.ingredientList, 
    this.ingredientName,
    this.recipeIngredient,
    super.key
  });

  Widget _ingredientNameInEditMode(){
    return Text(
      ingredientName!,
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
    );
  }

  Widget _ingredientNameInCreateMode(){
    return Expanded(
      flex: 3,
      child: FormBuilderField(
        name: "ingredientName$ingredientNumber",
        initialValue: (recipeIngredient != null) ? ingredientName : "",
        validator: FormBuilderValidators.required(errorText: "Required"),
        builder: (fieldState) {
          return DropdownSearch<String>(
            selectedItem: (recipeIngredient != null) ? ingredientName : null,
            items: (filter, loadProps) {
              return ingredientList.
                  where(
                    (item) => (item.name.toLowerCase().contains(filter.toLowerCase())),
                  )
                  .map((item) => item.name)
                  .toList();
            },
            // Search Bar
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(hintText: "Search ingredient"),
              ),
            ),
            decoratorProps: DropDownDecoratorProps(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                hintText: "Name",
                hintStyle: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print("${recipeIngredient != null}");
    print(RecipeIngredient.units[0]);
    print("--------------------");

    return Card(
      elevation: 6,
      shadowColor: Colors.orange[200],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: <Widget>[
            // INGREDIENT i-th
            Container(
              alignment: Alignment.centerLeft,
              child: Text("Ingredient ${ingredientNumber+1}:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),)
            ),
              
            Row(
              children: <Widget>[
                // INGREDIENT NAME
                (recipeIngredient != null) ? _ingredientNameInEditMode() : _ingredientNameInCreateMode(),
            
                SizedBox(width: 12),
            
                // INGREDIENT UNIT
                Expanded(
                  flex: 2,
                  child: FormBuilderDropdown<String>(
                    name: "ingredientUnit$ingredientNumber",
                    initialValue: (recipeIngredient != null) ? recipeIngredient!.unitMeasurement : RecipeIngredient.units[0],
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: "Required"),
                      (value){return (!RecipeIngredient.units.contains(value)) ? "Invalid input" : null;},
                    ]),
                    items: List.generate(RecipeIngredient.units.length, (index) {
                      return DropdownMenuItem(
                        value: RecipeIngredient.units[index],
                        child: Text(RecipeIngredient.units[index]),
                      );
                    }),
                  ),
                ),
            
                SizedBox(width: 12),
            
                // INGREDIENT QUANTITY
                Expanded(
                  child: FormBuilderTextField(
                    name: "ingredientQuantity$ingredientNumber",
                    initialValue: (recipeIngredient != null) ? recipeIngredient!.quantity.toString() : "",
                    validator: FormBuilderValidators.compose([
                      FormBuilderValidators.required(errorText: "Required"),
                      FormBuilderValidators.numeric(errorText: "Insert a number"),
                    ]),
                    decoration: InputDecoration(hintText: "1"),
                    keyboardType: TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.allow(RegExp(r"^\d+\.?\d?")),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      )
    );
  }
}
