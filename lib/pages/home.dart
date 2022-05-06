import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrustDetails {
  int id, defaultCrust;
  String name;
  Map crustSizes;

  CrustDetails({required this.id, required this.defaultCrust, required this.name, required this.crustSizes});
}
class PizzaDetails {
  String name, description;
  bool isVeg;
  int defaultCrust;
  List<CrustDetails> crustItems;

  PizzaDetails({required this.name, required this.description, required this.isVeg, required this.defaultCrust, required this.crustItems});
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

  bool _loading = true;

  Future<void> getDetails() async {
    debugPrint("In getDetails");
    String url = "https://625bbd9d50128c570206e502.mockapi.io/api/v1/pizza/1";
    var response = await http.get(Uri.parse(url));
    var jsonData = jsonDecode(response.body);
    statusCode = response.statusCode;
    statusMessage = response.reasonPhrase!;

    if(statusCode == 200) {
      String name, description;
      bool isVeg;
      int defaultCrust;
      String crustName;
      int id, defaultCrustId;
      Map crustSizes = {};
      CrustDetails crustItem;
      PizzaDetails pizzaItem;
      List<CrustDetails> crustItemList = [];

        name = jsonData['name'];
        isVeg = jsonData['isVeg'];
        description = jsonData['description'];
        defaultCrust = jsonData['defaultCrust'];
        crustItemList.clear();
        print(name);
        for(var crust in jsonData['crusts']) {
          id = crust['id'];
          crustName = crust['name'];
          for(var sizes in crust['sizes']) {
            crustSizes[sizes['name']] = sizes['price'];
            print(sizes['name']);
          }
          crustItem = CrustDetails(id: id, defaultCrust: defaultCrust, name: name, crustSizes: crustSizes);
          crustItemList.add(crustItem);
        }
        pizzaItem = PizzaDetails(name: name, description: description, isVeg: isVeg, defaultCrust: defaultCrust, crustItems: crustItemList);
        pizzaList.add(pizzaItem);
    }
    setState(() {
      _loading = false;
    });


    debugPrint(statusCode.toString());
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDetails();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Pizza Order"),
          centerTitle: true,
        ),
      body: Center(
        child: _loading? CircularProgressIndicator() : ListView.builder(
          itemCount: pizzaList.length,
            itemBuilder: (context, index) {
              return Container(
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Text(pizzaList[index].name),
                      Text(pizzaList[index].description),
                      Text(pizzaList[index].isVeg.toString()),
                      Text(pizzaList[index].crustItems.toString()),
                    ],
                  ),
                ),
              );
            }
        )
      ),
    );
  }
}
