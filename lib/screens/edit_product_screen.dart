import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';

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
  final _form = GlobalKey<FormState>();
  var _editedProduct =
      Product(id: null, title: '', price: 0, description: '', imageUrl: '');

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

  void _updateImageUrl() {
    if (!_imageUrlFocusNode.hasFocus) {
      setState(() {}); //rebuilt screen,though we don't set the state our self
    }
  }

  void _saveForm() {
    final isValid = _form.currentState
        .validate(); //trigger all validators. ALternatively, use autovalidate key in textformfield
    if (!isValid) {
      return; //stop function execution if validation fails
    }
    _form.currentState.save();
    print(_editedProduct.title);
    print(_editedProduct.imageUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Product'), actions: <Widget>[
        IconButton(
          icon: Icon(Icons.save),
          onPressed: _saveForm,
        )
      ]),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
            key: _form, //used for interacting with the form data in state
            child: ListView(
              children: [
                TextFormField(
                  decoration: InputDecoration(labelText: 'Title'),
                  textInputAction:
                      TextInputAction.next, //make bottom right button show next
                  //in soft keyboard instead of submit
                  onFieldSubmitted: (value) {
                    FocusScope.of(context).requestFocus(
                        _priceFocusNode); //use this to tell flutter
                    //form where to put the input focus after the submit/next button has been clicked
                  },
                  validator: (value) {
                    if (value.isEmpty) {
                      return 'Please provide a value';
                    }
                    return null;
                  },
                  onSaved: (newValue) {
                    _editedProduct = Product(
                        id: _editedProduct.id,
                        title: newValue,
                        description: _editedProduct.description,
                        price: _editedProduct.price,
                        imageUrl: _editedProduct.imageUrl);
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
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: _editedProduct.description,
                          price: double.parse(newValue),
                          imageUrl: _editedProduct.imageUrl);
                    }),
                TextFormField(
                    decoration: InputDecoration(labelText: 'Description'),
                    maxLines:
                        3, //automatically gives us a next button, so no need for text input action next
                    //however the enter button this time is for going to a new line
                    keyboardType: TextInputType.multiline,
                    focusNode: _decriptionFocusNode,
                    onSaved: (newValue) {
                      _editedProduct = Product(
                          id: _editedProduct.id,
                          title: _editedProduct.title,
                          description: newValue,
                          price: _editedProduct.price,
                          imageUrl: _editedProduct.imageUrl);
                    }),
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
                          onFieldSubmitted: (_) {
                            //an anonymous function is used here to call the function because calling the pointer directly won't work
                            //onFieldSubmitted by default would want a function that takes a string value as argument
                            _saveForm();
                          },
                          onSaved: (newValue) {
                            _editedProduct = Product(
                                id: _editedProduct.id,
                                title: _editedProduct.title,
                                description: _editedProduct.description,
                                price: _editedProduct.price,
                                imageUrl: newValue);
                          }),
                    )
                  ],
                )
              ],
            )),
      ),
    );
  }
}
