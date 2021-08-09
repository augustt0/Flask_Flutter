import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

import 'User.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Flask',
      theme: ThemeData(
        primarySwatch: Colors.purple,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = new GlobalKey<FormState>();

  bool loading = false;
  bool loading2 = false;

  User newUser = new User();

  String searchUsername = '';

  @override
  void initState() {
    super.initState();
  }

  void fetchUser(String username) async {
    // Search for a user
    setState(() {
      loading2 = true;
    });
    // We set our URL which will be our server's IP address, in this case it's my own computer so localhost (10.0.2.2 because im using an emulator)
    var url = 'http://10.0.2.2:5000/api/v1/retrieve/user/$username';

    // Wait for response
    var dio = Dio();

    var response = await dio.get(url,
        options: new Options(contentType: 'application/x-www-form-urlencoded'));

    // We check everything is okay by asking for the response code.
    if (response.statusCode == 200) {
      setState(() {
        loading2 = false;
      });
      // Request sent successfully

      // Check for internal server errors
      if (response.data['status'] == "SUCCESS") {
        User responseUser = new User(
          username: response.data['data']['username'],
          name: response.data['data']['name'],
          lastName: response.data['data']['lastname'],
          email: response.data['data']['email'],
          phone: response.data['data']['phone'],
        );
        // We show a dialog indicating success
        showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                  title: Text('Success'),
                  children: [
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text('Username ${responseUser.username}'),
                            Text('Name ${responseUser.name}'),
                            Text('Last name ${responseUser.lastName}'),
                            Text('Email ${responseUser.email}'),
                            Text('Phone ${responseUser.phone}'),
                          ],
                        ))
                  ],
                ));
      }else{
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text('Error'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        response.data['message']),
                  )
                ],
              ));
      }
    } else {
      setState(() {
        loading2 = false;
      });
      // There was an error
      print(response.data.toString());
      showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text('Error'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        'Error when trying to search ${newUser.username} in the database.'),
                  )
                ],
              ));
    }
  }

  void sendData() async {
    // Upload data to server
    setState(() {
      loading = true;
    });

    // We set our URL which will be our server's IP address, in this case it's my own computer so localhost (10.0.2.2 because im using an emulator)
    var url = 'http://10.0.2.2:5000/api/v1/uploads/users';

    // Create the body
    Map<String, dynamic> msj = {
      "username": newUser.username,
      "name": newUser.name,
      "lastname": newUser.lastName,
      "email": newUser.email,
      "phone": newUser.phone.toString()
    };

    // Encode message as json
    String jsonString = json.encode(msj);

    print(msj);

    // Wait for response
    var dio = Dio();

    var response = await dio.post(url,
        data: msj,
        options: new Options(contentType: 'application/x-www-form-urlencoded'));

    // We check everything is okay by asking for the response code.
    if (response.statusCode == 200) {
      // Request sent successfully

      // Check for internal server errors
      if (response.data['status'] == "SUCCESS") {
        setState(() {
          loading = false;
        });
        // We show a dialog indicating success
        showDialog(
            context: context,
            builder: (context) => SimpleDialog(
                  title: Text('Success'),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child:
                          Text('User ${newUser.username} was added correctly'),
                    )
                  ],
                ));
      }else{
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text('Error'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        response.data['message']),
                  )
                ],
              ));
      }
    } else {
      setState(() {
        loading = false;
      });
      // There was an error
      print(response.data.toString());
      showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text('Error'),
                children: [
                  Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                        'Error when trying to add ${newUser.username} to the database.'),
                  )
                ],
              ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter + Flask ❤'),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Form(
              key: _formKey,
              child: loading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Padding(
                      padding: EdgeInsets.only(left: 10, right: 10, bottom: 10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'Create new user',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 30),
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            'Username',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Username',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field is required.';
                              } else {
                                newUser.username = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Name',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Name',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field is required.';
                              } else {
                                newUser.name = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Last name',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Last name',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field is required.';
                              } else {
                                newUser.lastName = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 12,
                          ),
                          Text(
                            'Email',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Email',
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field is required.';
                              } else {
                                newUser.email = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            'Phone',
                            style: TextStyle(
                                fontWeight: FontWeight.w300, fontSize: 14),
                          ),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Phone',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: <TextInputFormatter>[
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            maxLength: 20,
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'This field is required.';
                              } else {
                                newUser.phone = value;
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          TextButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_formKey.currentState.validate() &&
                                    !loading) {
                                  sendData();
                                } else {}
                              },
                              child: Text('Upload user'))
                        ],
                      ),
                    ),
            ),
            Divider(),
            SizedBox(
              height: 15,
            ),
            Text(
              'Search user',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
            ),
            loading2
                ? Center(
                    child: CircularProgressIndicator(),
                  )
                : Column(
                    children: [
                      Column(
                        children: [
                          TextField(
                            decoration: InputDecoration(
                                border: OutlineInputBorder(),
                                hintText: 'Search username'),
                            onChanged: (text) => searchUsername = text,
                          ),
                          TextButton(
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (searchUsername.isNotEmpty && !loading2) {
                                  fetchUser(searchUsername);
                                } else {
                                  showDialog(
                                      context: context,
                                      builder: (context) => SimpleDialog(
                                            title: Text('Error'),
                                            children: [
                                              Padding(
                                                padding: EdgeInsets.all(10),
                                                child: Text(
                                                    'You must insert a search term.'),
                                              )
                                            ],
                                          ));
                                }
                              },
                              child: Text('Search user')),
                        ],
                      )
                    ],
                  )
          ],
        ),
      ),
    );
  }
}
