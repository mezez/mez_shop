import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:http/http.dart' as http;

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
  final String authToken;
  final String userId;

  Orders(this.authToken, this.userId, this._orders);

  List<OrderItem> get orders {
    return [
      ..._orders
    ]; //returning a new list so that orders cannot be modified outside this class
  }

  void addOrder(List<CartItem> cartProducts, double total) async {
    final url =
        'https://mez-shop.firebaseio.com/orders/$userId.json?auth=$authToken';
    final timestamp = DateTime.now();
    //you can add a try catch here to handle errors
    final response = await http.post(url,
        body: json.encode({
          'amount': total,
          'dateTime': timestamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList()
        }));

    //_orders.add(value) //add new order to the end of the list
    _orders.insert(
        0,
        OrderItem(
            id: json.decode(response.body)['name'], //firebase autogenerated id
            amount: total,
            products: cartProducts,
            dateTime: timestamp)); //add new order to the beginning of the list
    notifyListeners();
  }

  Future<void> fetchAndSetOrders() async {
    final url =
        'https://mez-shop.firebaseio.com/orders/$userId.json?auth=$authToken';
    final response = await http.get(url);
    final List<OrderItem> loadedOrders = [];
    // print(json.decode(response.body));
    final extractedData = json.decode(response.body) as Map<String, dynamic>;
    if (extractedData == null) {
      return;
    }
    extractedData.forEach((orderId, orderData) {
      loadedOrders.add(OrderItem(
          id: orderId,
          amount: orderData['amount'],
          products: (orderData['products'] as List<dynamic>)
              .map((item) => CartItem(
                  id: item['id'],
                  price: item['price'],
                  quantity: item['quantity'],
                  title: item['title']))
              .toList(),
          dateTime: DateTime.parse(orderData['dateTime'])));
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
