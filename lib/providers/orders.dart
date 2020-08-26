import 'package:flutter/foundation.dart';
import 'package:my_shop/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  List<OrderItem> _orders = [];

  List<OrderItem> get orders {
    return [
      ...orders
    ]; //returning a new list so that orders cannot be modified outside this class
  }

  void addOrder(List<CartItem> cartProducts, double total) {
    //_orders.add(value) //add new order to the end of the list
    _orders.insert(
        0,
        OrderItem(
            id: DateTime.now().toString(),
            amount: total,
            products: cartProducts,
            dateTime:
                DateTime.now())); //add new order to the beginning of the list
    notifyListeners();
  }
}
