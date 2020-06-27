import 'package:diabapp/services/barcode_scan.dart';
import 'package:diabapp/widgets/data_search_bar.dart';
import 'package:diabapp/widgets/newDropDown.dart';
import 'package:flutter/material.dart';
import 'package:diabapp/data/open_food_facts_database.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:diabapp/main.dart';

class FoodSearch extends StatefulWidget {
  @override
  _FoodSearchState createState() => _FoodSearchState();
}

class _FoodSearchState extends State<FoodSearch> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Search"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              final database =
                  Provider.of<OpenFoodFactsDataBase>(context, listen: false);
              var queryDB;
              switch (
                  Provider.of<MealItems>(context, listen: false).searchType) {
                case "Food":
                  queryDB = database.containsValue;
                  break;
                case "Meal":
                  queryDB = database.equalsValue;
                  break;
                default:
              }
              showSearch(
                  context: context,
                  delegate: DataSearch(queryDB,
                      initialSuggestions: database.watchAllTasks));
            },
          ),
          MyDropdownFilled(dropDownValues: ["Food", "Meal", "Custom"]),
          IconButton(
            icon: Icon(Icons.camera),
            onPressed: () {
              var foodItem = scan().then((value) =>
                  Provider.of<OpenFoodFactsDataBase>(context, listen: false)
                      .getCode(value.rawContent));
              foodItem.then((value) => value != null
                  ? Provider.of<MealItems>(context, listen: false)
                      .addFood(value)
                  : print("Not found"));
            },
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(child: FoodList()),
          TextAndIconButton(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        tooltip: 'Pick Image',
        child: Icon(Icons.add),
      ),
    );
  }
}

class FoodList extends StatefulWidget {
  const FoodList({
    Key key,
  }) : super(key: key);

  @override
  _FoodListState createState() => _FoodListState();
}

class _FoodListState extends State<FoodList> {
  @override
  Widget build(BuildContext context) {
    return Consumer<MealItems>(builder: (context, myMeal, child) {
      return ListView.builder(
        itemBuilder: (context, index) => Slidable(
          actionPane: SlidableDrawerActionPane(),
          secondaryActions: <Widget>[
            IconSlideAction(
              caption: 'Delete',
              color: Colors.red,
              icon: Icons.delete,
              onTap: () => myMeal.removeFood(index),
            )
          ],
          child: Card(
            child: ListTile(
              onTap: () {},
              leading: Icon(
                Icons.restaurant,
                size: 50.0,
              ),
              title: Text(myMeal.foodList[index].productName ?? "undefined"),
              subtitle: Text(myMeal.foodList[index].brands ?? "Unknown brand"),
            ),
          ),
        ),
        itemCount: myMeal.foodList.length,
      );
    });
  }
}

class TextAndIconButton extends StatelessWidget {
  final TextEditingController _textFieldController = TextEditingController();

  _displayDialog(BuildContext context) async {
    var foodDb = Provider.of<OpenFoodFactsDataBase>(context, listen: false);
    var fooditems = Provider.of<MealItems>(context, listen: false).foodList;
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text("Enter name for your meal"),
            content: TextField(
              controller: _textFieldController,
              decoration: InputDecoration(hintText: "My meal"),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('SAVE'),
                onPressed: () {
                  Provider.of<MealItems>(context, listen: false).mealName =
                      _textFieldController.text;
                  foodDb.createEmptyMeal().then((value) {
                    value.foodItems = fooditems;
                    foodDb.writeMeal(value);
                  });
                  Navigator.of(context).pop();
                },
              ),
              FlatButton(
                child: Text('CANCEL'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RaisedButton.icon(
        icon: Icon(Icons.save),
        label: Text('Save'),
        onPressed: () => _displayDialog(context),
      ),
    );
  }
}
