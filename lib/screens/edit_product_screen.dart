import 'package:flutter/material.dart';

class EditProductScreen extends StatefulWidget {
  static const routeName = '/edit-product';
  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _priceFocusNode = FocusNode();
  final _decriptionFocusNode = FocusNode();
  final _imageUrlController = TextEditingController();
  final _imageUrlFocusNode = FocusNode();

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

//clear focus nodes when state gets cleared to avoid memory leak
  @override
  void dispose() {
    _imageUrlFocusNode.removeListener(_updateImageUrl);
    _priceFocusNode.dispose();
    _decriptionFocusNode.dispose();
    _imageUrlController.dispose();
    super.dispose();
  }

  _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {}); //rebuilt screen,though we don't set the state our self
    }
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
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  margin: EdgeInsets.only(top: 8, right: 10),
                  decoration: BoxDecoration(
                      border: Border.all(width: 1, color: Colors.grey)),
                  child: _imageUrlController.text.isEmpty
                      ? Text('Enter a URL')
                      : FittedBox(
                          child: Image.network(
                            _imageUrlController.text,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
                //note that textformfields takes as much width as it can get, so this will be problematic as a direct child
                // of a row which is unbounded by default
                Expanded(
                  child: TextFormField(
                    decoration: InputDecoration(labelText: 'Image URL'),
                    keyboardType: TextInputType.url,
                    textInputAction: TextInputAction.done,
                    controller:
                        _imageUrlController, //using controller as we want to get the input value BEFORE the form is submitted
                    focusNode: _imageUrlFocusNode,
                  ),
                )
              ],
            )
          ],
        )),
      ),
    );
  }
}
