import 'package:flutter/material.dart';
import 'package:my_shop/helpers/custom_route.dart';
import 'package:my_shop/providers/auth.dart';
import 'package:my_shop/providers/cart.dart';
import 'package:my_shop/providers/orders.dart';
import 'package:my_shop/screens/cart_screen.dart';
import 'package:my_shop/screens/edit_product_screen.dart';
import 'package:my_shop/screens/orders_screen.dart';
import 'package:my_shop/screens/product_detail_screen.dart';
import 'package:my_shop/screens/products_overview_screen.dart';
import 'package:my_shop/screens/splash_screen.dart';
import 'package:my_shop/screens/user_products_screen.dart';
import 'package:my_shop/screens/auth_screen.dart';
import 'package:provider/provider.dart';

import './providers/products.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //alternative, applicable when the provided context is not really needed, also better suited for builder methods
    // return ChangeNotifierProvider.value(
    //   value: (ctx) => Products(),
    //   ...
    return MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: Auth()),
          ChangeNotifierProxyProvider<Auth, Products>(
            //suitable for passing paramter to the provider constructor
            create: null,
            update: (ctx, auth, previousProducts) => Products(
                auth.token,
                auth.userId,
                previousProducts == null ? [] : previousProducts.items),
          ),
          ChangeNotifierProvider(
            create: (ctx) => Cart(),
          ),
          ChangeNotifierProxyProvider<Auth, Orders>(
              create: null,
              update: (ctx, auth, previousOrders) => Orders(
                  auth.token,
                  auth.userId,
                  previousOrders == null ? [] : previousOrders.orders)),
          // ChangeNotifierProvider.value(value: Orders()),
        ],
        child:

            //rebuild material app whenever auth object( provider) changes
            Consumer<Auth>(
          builder: (ctx, auth, _) => MaterialApp(
            title: 'Flutter Demo',
            theme: ThemeData(
              primarySwatch: Colors.purple,
              accentColor: Colors.deepOrange,
              fontFamily: 'Lato',

              //OPTIONAL. THIS OVERRIDES DEFAULT FLUTTER BEHAVIOUR
              //ADD CUSTOM PAGE TRANSITION ON AN APP-WIDE LEVEL. SEE HELPERS FOLDER
              pageTransitionsTheme: PageTransitionsTheme(builders: {
                TargetPlatform.android: CustomPageTransitionBuilder(),
                TargetPlatform.iOS: CustomPageTransitionBuilder(),
              }),
              visualDensity: VisualDensity.adaptivePlatformDensity,
            ),
            home: auth.isAuth
                ? ProductsOverViewScreen()
                : FutureBuilder(
                    future: auth.tryAutoLogin(),
                    builder: (ctx, authResultSnapshot) =>
                        authResultSnapshot.connectionState ==
                                ConnectionState.waiting
                            ? SplashScreen()
                            : AuthScreen()),
            routes: {
              // ProductsOverViewScreen.routeName: (ctx) => ProductsOverViewScreen(),
              ProductDetailScreen.routeName: (ctx) => ProductDetailScreen(),
              CartScreen.routeName: (ctx) => CartScreen(),
              OrdersScreen.routeName: (ctx) => OrdersScreen(),
              UserProductsScreen.routeName: (ctx) => UserProductsScreen(),
              EditProductScreen.routeName: (ctx) => EditProductScreen(),
            },
          ),
        ));
  }
}
