//mixin class
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'
    as http; //prevent name clashes as this package bundles many features
import 'package:my_shop/models/http_exception.dart';
import 'dart:convert';

import './product.dart';

//mix in change notifier with products class
class Products with ChangeNotifier {
  List<Product> _items = [
    // Product(
    //   id: 'p1',
    //   title: 'Red Shirt',
    //   description: 'A red shirt - it is pretty red!',
    //   price: 29.99,
    //   imageUrl:
    //       'https://cdn.pixabay.com/photo/2016/10/02/22/17/red-t-shirt-1710578_1280.jpg',
    // ),
    // Product(
    //   id: 'p2',
    //   title: 'Trousers',
    //   description: 'A nice pair of trousers.',
    //   price: 59.99,
    //   imageUrl:
    //       'https://upload.wikimedia.org/wikipedia/commons/f/fb/Trousers.jpg',
    // ),
    // Product(
    //   id: 'p3',
    //   title: 'Yellow Scarf',
    //   description: 'Warm and cozy - exactly what you need for the winter.',
    //   price: 19.99,
    //   imageUrl:
    //       'https://live.staticflickr.com/4043/4438260868_cc79b3369d_z.jpg',
    // ),
    // Product(
    //     id: 'p4',
    //     title: 'A Pan',
    //     description: 'Prepare any meal you want.',
    //     price: 49.99,
    //     imageUrl:
    //         'https://upload.wikimedia.org/wikipedia/commons/thumb/1/14/Cast-Iron-Pan.jpg/1200px-Cast-Iron-Pan.jpg'),
  ];

  // var _showFavouritesOnly = false;

  final String authToken;
  final String userId;

  Products(this.authToken, this.userId, this._items);

  List<Product> get items {
    // if (_showFavouritesOnly) {
    //   return _items.where((prodItem) => prodItem.isFavourite).toList();
    // }
    return [
      ..._items
    ]; //returning a new list so that items cannot be modified outside this class
  }

  List<Product> get favouriteItems {
    return _items.where((prodItem) => prodItem.isFavourite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((prod) => prod.id == id);
  }

  Future<void> fetchAndSetProducts([bool filterByUser = false]) async {
    final filterString =
        filterByUser ? 'orderBy="creatorId"&equalTo="$userId"' : '';
    var url =
        'https://mez-shop.firebaseio.com/products.json?auth=$authToken&$filterString'; //fetch products
    try {
      final response = await http.get(url);
      // print(json.decode(response.body));
      final extractedData =
          json.decode(response.body) as Map<String, dynamic>; //dynamic tells
      //flutter that the values are dynamic, (nice in event of being unsure about data type). Can use Object to in this
      //particular case
      if (extractedData == null) {
        return;
      }
      //fetch favourite status
      url =
          'https://mez-shop.firebaseio.com/userFavourites/$userId.json?auth=$authToken';
      final favouriteResponse = await http.get(url);
      final favouriteData = json.decode(favouriteResponse.body);
      final List<Product> loadedProducts = [];
      extractedData.forEach((prodId, prodData) {
        loadedProducts.add(Product(
            id: prodId,
            title: prodData['title'],
            description: prodData['description'],
            price: prodData['price'],
            isFavourite:
                favouriteData == null ? false : favouriteData[prodId] ?? false,
            imageUrl: prodData[
                'imageUrl'])); //?? checks if favouriteData[prodId] is null defaults to false if so
      });
      _items = loadedProducts;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  // void showFavouritesOnly() {
  //   _showFavouritesOnly = true;
  //   notifyListeners();
  // }

  // void showAll() {
  //   _showFavouritesOnly = false;
  //   notifyListeners();
  // }

  //callback/promise based

  // Future<void> addProduct(Product product) {
  //   const url = 'https://mez-shop.firebaseio.com/products.json';
  //   //send post request
  //   //post returns a future and we use this async feature to toggle a spinner where add product is being used
  //   //hence the return for the return statement below
  //   return http
  //       .post(url,
  //           body: json.encode({
  //             'title': product.title,
  //             'description': product.description,
  //             'imageUrl': product.imageUrl,
  //             'price': product.price,
  //             'isFavourite': product.isFavourite,
  //           }))
  //       .then((response) {
  //     //save new product after it saves in firebase
  //     print(json.decode(response.body));
  //     final newProduct = Product(
  //         title: product.title,
  //         description: product.description,
  //         price: product.price,
  //         imageUrl: product.imageUrl,
  //         id: json.decode(response.body)['name'] //id generated by firebase
  //         );
  //     _items.add(newProduct);
  //     //_items.insert(0, newProduct); //alternative add product to the start of the list
  //     notifyListeners();
  //   }).catchError((error) {
  //     print(error);
  //     throw error;
  //   });
  // }

  //async/await and try/catch approach
  Future<void> addProduct(Product product) async {
    final url = 'https://mez-shop.firebaseio.com/products.json?auth=$authToken';
    //send post request
    //post returns a future and we use this async feature to toggle a spinner where add product is being used
    //hence the return for the return statement below
    try {
      final response = await http.post(url,
          body: json.encode({
            'title': product.title,
            'description': product.description,
            'imageUrl': product.imageUrl,
            'price': product.price,
            'creatorId': userId
          }));

      //save new product after it saves in firebase
      // print(json.decode(response.body));
      final newProduct = Product(
          title: product.title,
          description: product.description,
          price: product.price,
          imageUrl: product.imageUrl,
          id: json.decode(response.body)['name'] //id generated by firebase
          );
      _items.add(newProduct);
      //_items.insert(0, newProduct); //alternative add product to the start of the list
      notifyListeners();
    } catch (error) {
      print(error);
      throw error;
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final prodIndex = _items.indexWhere((prod) => prod.id == id);
    if (prodIndex >= 0) {
      final url =
          'https://mez-shop.firebaseio.com/products/$id.json?auth=$authToken';
      try {
        await http.patch(url,
            body: json.encode({
              'title': newProduct.title,
              'description': newProduct.description,
              'imageUrl': newProduct.imageUrl,
              'price': newProduct.price,
            }));
      } catch (error) {
        print(error);
      }
      _items[prodIndex] = newProduct;
      notifyListeners();
    } else {
      print('...');
    }
  }

  Future<void> deleteProduct(String id) async {
    final url =
        'https://mez-shop.firebaseio.com/products/$id.json?auth=$authToken';
    //optimistic updating (deleting)
    final existingProductIndex = _items.indexWhere((prod) => prod.id == id);
    var existingProduct = _items[existingProductIndex];
    final response = await http.delete(url);
    _items.removeAt(
        existingProductIndex); //remove item from list but not in memory. We still have reference to it above
    notifyListeners();

    if (response.statusCode >= 400) {
      //re-insert the item to the list at its original index if deletion fails.
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      //throw custom error
      throw HttpException(
          'Could not delete product.'); //A custom exception class
    }
    existingProduct =
        null; //clear the reference in memory, flutter handles the rest of cleanup
  }
}
