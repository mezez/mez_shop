import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _decriptionFocusNode = FocusNode();

//clear focus nodes when state gets cleared to avoid memory leak
  @override
  void dispose() {
    _priceFocusNode.dispose();
    _decriptionFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Product'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            child: ListView(
          children: [
            TextFormField(
              decoration: InputDecoration(labelText: 'Title'),
              textInputAction:
                  TextInputAction.next, //make bottom right button show next
              //in soft keyboard instead of submit
              onFieldSubmitted: (value) {
                FocusScope.of(context)
                    .requestFocus(_priceFocusNode); //use this to tell flutter
                //form where to put the input focus after the submit/next button has been clicked
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Price'),
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.number,
              focusNode: _priceFocusNode,
              onFieldSubmitted: (_) {
                FocusScope.of(context).requestFocus(_decriptionFocusNode);
              },
            ),
            TextFormField(
              decoration: InputDecoration(labelText: 'Description'),
              maxLines:
                  3, //automatically gives us a next button, so no need for text input action next
              //however the enter button this time is for going to a new line
              keyboardType: TextInputType.multiline,
              focusNode: _decriptionFocusNode,
            ),
          ],
        )),
      ),
    );
  }
}
