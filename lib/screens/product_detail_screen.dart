import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:my_shop/providers/products.dart';

class ProductDetailScreen extends StatelessWidget {
  // final String title;

  // ProductDetailScreen(this.title);

  static const routeName = 'product-detail';
  @override
  Widget build(BuildContext context) {
    final productId = ModalRoute.of(context).settings.arguments as String;
    final loadedProduct =
        Provider.of<Products>(context, listen: false).findById(productId);
    //listen is true by default, Here we are stopping it from listening so that
    //the widget does not rebuild if changes are made to the provider/global data storage
    //findById is defined in the provider class
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(loadedProduct.title),
      // ),
      backgroundColor: null,
      body: CustomScrollView(
        slivers: [
          //scrollable areas on the screen
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(loadedProduct.title),
              background: Hero(
                tag: loadedProduct.id,
                child: Image.network(
                  loadedProduct.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverList(
              delegate: SliverChildListDelegate([
            SizedBox(
              height: 10,
            ),
            Text(
              '\$${loadedProduct.price}',
              style: TextStyle(color: Colors.grey, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: 10,
            ),
            Container(
                padding: EdgeInsets.symmetric(horizontal: 10),
                child: Text(
                  loadedProduct.description,
                  textAlign: TextAlign.center,
                  softWrap: true,
                )),
            SizedBox(
              height: 800,
            )
          ]))
        ],
        // child: Column(
        //   children: [
        //     Container(
        //       width: double.infinity,
        //       height: 300,
        //       child: Hero(
        //         tag: loadedProduct.id,
        //         child: Image.network(
        //           loadedProduct.imageUrl,
        //           fit: BoxFit.cover,
        //         ),
        //       ),
        //     ),

        //   ],
        // ),
      ),
    );
  }
}
