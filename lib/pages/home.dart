import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class PizzaDetails {
  String name, description;
  bool isVeg;
  int defaultCrust;

  PizzaDetails({required this.name, required this.description, required this.isVeg, required this.defaultCrust});
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List<PizzaDetails> pizzaList = [];

  //Status Code for the http request
  late int statusCode;
  late String statusMessage;

  Future<void> getDetails() async {
    debugPrint("In getDetails");
    String url = "https://625bbd9d50128c570206e502.mockapi.io/api/v1/pizza/1";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    statusCode = response.statusCode;
    statusMessage = response.reasonPhrase!;

    debugPrint(statusCode.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pizza Order"),
          centerTitle: true,
        ),
      body: Center(
        child: ElevatedButton(
          child: Text("Get pizza details"),
          onPressed: () {
            getDetails();
          },
        )
      ),
    );
  }
}
