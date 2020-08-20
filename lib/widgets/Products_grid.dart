import 'package:flutter/material.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

import 'package:my_shop/widgets/products_item.dart';

class ProductsGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //this can only be used to listen in a provider has been setup for a parent widget
    //here we specify that we are listening to direct communications instance of the products in the provider class
    final productsData = Provider.of<Products>(context);
    final products = productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10.0),
      itemCount: products.length,
      itemBuilder: (ctx, i) => ChangeNotifierProvider(
          create: (c) => products[i],
          child: ProductItem(
              // products[i].id,
              // products[i].title,
              // products[i].imageUrl
              )),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, //number of colums
        childAspectRatio: 3 / 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ), //defines how the grid should be generally structured
    );
  }
}
