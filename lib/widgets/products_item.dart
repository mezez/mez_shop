import 'package:flutter/material.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:provider/provider.dart';

class ProductItem extends StatelessWidget {
  // final String id;
  // final String title;
  // final String imageUrl;

  // ProductItem(this.id, this.title, this.imageUrl);

  @override
  Widget build(BuildContext context) {
    final product =
        Provider.of<Product>(context); //listen to the product provider
    final cart = Provider.of<Cart>(context, listen: false);
    return ClipRRect(
      //CLip Rounded Rectangles
      borderRadius: BorderRadius.circular(10),
      child: GridTile(
        child: GestureDetector(
          onTap: () {
            //CREATE ROUTE ON THE FLY
            // Navigator.of(context).push(MaterialPageRoute(
            //     builder: (ctx) => ProductDetailScreen(title)));

            //NAMED ROUTE
            Navigator.of(context).pushNamed(ProductDetailScreen.routeName,
                arguments: product.id);
          },
          child: Image.network(
            product.imageUrl,
            fit: BoxFit.cover,
          ),
        ),
        footer: GridTileBar(
          leading: IconButton(
            icon: Icon(
                product.isFavourite ? Icons.favorite : Icons.favorite_border),
            onPressed: () {
              product.toggleFavouriteStatus();
            },
            color: Theme.of(context).accentColor,
          ),
          trailing: IconButton(
            icon: Icon(Icons.shopping_cart),
            onPressed: () {
              cart.addItem(product.id, product.price, product.title);
              Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                  'Added item to cart',
                ),
                duration: Duration(seconds: 2), //duration is option
                action: SnackBarAction(label: 'UNDO', onPressed: () {}),
              ));
            },
            color: Theme.of(context).accentColor,
          ),
          backgroundColor: Colors.black87,
          title: Text(
            product.title,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
