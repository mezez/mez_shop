//mixin class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/product.dart';

//mix in change notifier with products class
class Products with ChangeNotifier {
  List<Product> _items = [];

  List<Product> get items {
    return [...items];
  }

  void addProduct() {
    // _items.add(value);
    notifyListeners();
  }
}
