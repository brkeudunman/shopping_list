import 'package:shopping_list/data/categories.dart';

import '../models/categories.dart';
import '../models/grocery_item.dart';

List<GroceryItem> groceryItems = [
  GroceryItem(
      name: 'Milk',
      id: 'a',
      quantity: 1,
      category: categories[Categories.dairy]!),
  GroceryItem(
      id: 'b',
      name: 'Bananas',
      quantity: 5,
      category: categories[Categories.fruit]!),
  GroceryItem(
      id: 'c',
      name: 'Beef Steak',
      quantity: 1,
      category: categories[Categories.meat]!),
];