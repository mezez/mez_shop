import 'package:flutter/material.dart';
import 'package:my_shop/providers/orders.dart'
    show Orders; //we need only orders to avoid name clash
import 'package:my_shop/widgets/app_drawer.dart';
import 'package:my_shop/widgets/order_item.dart';
import 'package:provider/provider.dart';

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders';

  @override
  Widget build(BuildContext context) {
    print('Building orders');
    // final orderData = Provider.of<Orders>(context);
    return Scaffold(
        appBar: AppBar(
          title: Text('Your Orders'),
        ),
        drawer: AppDrawer(),
        body: FutureBuilder(
          future:
              Provider.of<Orders>(context, listen: false).fetchAndSetOrders(),
          builder: (ctx, dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                //do error handling
                return Center(
                  child: Text('An error occurred'),
                );
              } else {
                //no error
                //use consumer as alternative to setting provider listener above which leads to an infinite loop when fetch and set orders triggers notify listeners
                return Consumer<Orders>(
                    builder: (ctx, orderData, child) => ListView.builder(
                        itemCount: orderData.orders.length,
                        itemBuilder: (ctx, i) =>
                            OrderItem(orderData.orders[i])));
              }
            }
          },
        ));
  }
}
