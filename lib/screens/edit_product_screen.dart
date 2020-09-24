import 'package:flutter/material.dart';
import 'package:my_shop/providers/product.dart';
import 'package:my_shop/providers/products.dart';
import 'package:provider/provider.dart';

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
  var _initValues = {
    'title': '',
    'price': '',
    'description': '',
    'imageUrl': '',
  };
  var _isInit = true;
  var _isLoading = false;

  @override
  void initState() {
    _imageUrlFocusNode.addListener(_updateImageUrl);
    super.initState();
  }

  @override
  void didChangeDependencies() {
    if (_isInit) {
      final productId = ModalRoute.of(context).settings.arguments
          as String; //this is set as string because there is only one parameter expected
      if (productId != null) {
        _editedProduct =
            Provider.of<Products>(context, listen: false).findById(productId);
      }
      _initValues = {
        'title': _editedProduct.title,
        'description': _editedProduct.description,
        'price': _editedProduct.price.toString(),
        // 'imageUrl': _editedProduct.imageUrl,
        'imageUrl': null
      };
      _imageUrlController.text = _editedProduct.imageUrl;
    }
    _isInit = false;
    super.didChangeDependencies();
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
      if (_imageUrlController.text.isEmpty ||
          !_imageUrlController.text.startsWith('http') ||
          !_imageUrlController.text.endsWith('.png') ||
          !_imageUrlController.text.endsWith('jpg') ||
          !_imageUrlController.text.endsWith('.jpeg')) {
        return;
      }
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
    setState(() {
      _isLoading = true;
    });
    //add product to products list
    if (_editedProduct.id != null) {
      //we are updating an existing product
      Provider.of<Products>(context, listen: false)
          .updateProduct(_editedProduct.id, _editedProduct);
    } else {
      Provider.of<Products>(context, listen: false)
          .addProduct(_editedProduct)
          .catchError((error) {
        return showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
                  title: Text('An error occurred!'),
                  // content: Text(error.toString()), //this sometimes could contain sensitive information that should not be seen by the user
                  content: Text('Something went wrong.'),
                  actions: [
                    FlatButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                        },
                        child: Text('Okay'))
                  ],
                ));
      }).then((_) {
        setState(() {
          _isLoading = false;
        });
        Navigator.of(context).pop(); //return to previous page
      });
    }
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                  key: _form, //used for interacting with the form data in state
                  child: ListView(
                    children: [
                      TextFormField(
                        initialValue: _initValues['title'],
                        decoration: InputDecoration(labelText: 'Title'),
                        textInputAction: TextInputAction
                            .next, //make bottom right button show next
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
                            imageUrl: _editedProduct.imageUrl,
                            isFavourite: _editedProduct.isFavourite,
                          );
                        },
                      ),
                      TextFormField(
                          initialValue: _initValues['price'],
                          decoration: InputDecoration(labelText: 'Price'),
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          focusNode: _priceFocusNode,
                          onFieldSubmitted: (_) {
                            FocusScope.of(context)
                                .requestFocus(_decriptionFocusNode);
                          },
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a price';
                            }
                            if (double.tryParse(value) == null) {
                              return 'Please enter a valid number';
                            }
                            if (double.parse(value) <= 0) {
                              return 'Please enter a number greater than 0';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: _editedProduct.description,
                              price: double.parse(newValue),
                              imageUrl: _editedProduct.imageUrl,
                              isFavourite: _editedProduct.isFavourite,
                            );
                          }),
                      TextFormField(
                          initialValue: _initValues['description'],
                          decoration: InputDecoration(labelText: 'Description'),
                          maxLines:
                              3, //automatically gives us a next button, so no need for text input action next
                          //however the enter button this time is for going to a new line
                          keyboardType: TextInputType.multiline,
                          focusNode: _decriptionFocusNode,
                          validator: (value) {
                            if (value.isEmpty) {
                              return 'Please enter a description';
                            }
                            if (value.length < 10) {
                              return 'Should be at least 10 characters long';
                            }
                            return null;
                          },
                          onSaved: (newValue) {
                            _editedProduct = Product(
                              id: _editedProduct.id,
                              title: _editedProduct.title,
                              description: newValue,
                              price: _editedProduct.price,
                              imageUrl: _editedProduct.imageUrl,
                              isFavourite: _editedProduct.isFavourite,
                            );
                          }),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.only(top: 8, right: 10),
                            decoration: BoxDecoration(
                                border:
                                    Border.all(width: 1, color: Colors.grey)),
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
                                // initialValue: _initValues['imageUrl'], //cannot use this here since a controllee is being used
                                decoration:
                                    InputDecoration(labelText: 'Image URL'),
                                keyboardType: TextInputType.url,
                                textInputAction: TextInputAction.done,
                                controller:
                                    _imageUrlController, //using controller as we want to get the input value BEFORE the form is submitted
                                focusNode: _imageUrlFocusNode,
                                validator: (value) {
                                  if (value.isEmpty) {
                                    return 'Please enter an image url';
                                  }
                                  if (!value.startsWith('http') ||
                                      !value.startsWith('https')) {
                                    return 'Please enter a valid url';
                                  }
                                  if (!value.endsWith('.png') &&
                                      !value.endsWith('jpg') &&
                                      !value.endsWith('.jpeg')) {
                                    return 'Please enter a valid image url';
                                  }

                                  return null;
                                },
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
                                    imageUrl: newValue,
                                    isFavourite: _editedProduct.isFavourite,
                                  );
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
