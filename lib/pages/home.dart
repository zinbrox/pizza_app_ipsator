import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CrustDetails {
  int id, defaultCrust;
  String name;
  List crustSizes, crustCosts;

  CrustDetails({required this.id, required this.defaultCrust, required this.name, required this.crustSizes, required this.crustCosts});
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

      CrustDetails crustItem;
      PizzaDetails pizzaItem;
      List<CrustDetails> crustItemList = [];
      List<String> crustSizes = [];
      List<int> crustCosts = [];

        name = jsonData['name'];
        isVeg = jsonData['isVeg'];
        description = jsonData['description'];
        defaultCrust = jsonData['defaultCrust'];
        crustItemList.clear();
        for(var crust in jsonData['crusts']) {
          id = crust['id'];
          crustName = crust['name'];
          crustSizes.clear();
          crustCosts.clear();
          for(var sizes in crust['sizes']) {
            //crustSizes[sizes['name']] = sizes['price'];
            crustSizes.add(sizes['name']);
            crustCosts.add(sizes['price']);

          }
          crustItem = CrustDetails(id: id, defaultCrust: defaultCrust, name: crustName, crustSizes: crustSizes.toList(), crustCosts: crustCosts.toList());
          crustItemList.add(crustItem);
          //show crust type sizes
          debugPrint(crustItem.crustSizes.toString());
        }
        //show 1st crust type sizes
        debugPrint(crustItemList[0].crustSizes.toString());
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
        child: _loading? const CircularProgressIndicator() : ListView.builder(
          itemCount: pizzaList.length,
            itemBuilder: (context, index) {
              return InkWell(
                onTap: () {
                  debugPrint("Pressed on Pizza");

                },
                child: Card(
                  elevation: 5,
                  child: Column(
                    children: [
                      Text(pizzaList[index].name),
                      Text(pizzaList[index].description),
                      Text(pizzaList[index].isVeg.toString()),
                      ElevatedButton(
                          onPressed: () async {
                            debugPrint("Pressed Add to Cart");
                            await showModalBottomSheet(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                    builder: (context, setState) {
                                      return Container(
                                        height: 600,
                                        decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(10),
                                              topRight: Radius.circular(10)),
                                        ),
                                        child: ListView.builder(
                                            itemCount: pizzaList[index].crustItems.length,
                                            itemBuilder: (context, i) {
                                              return Column(
                                                children: [
                                                  Text(pizzaList[index].crustItems[i].name),
                                                  SizedBox(
                                                    height: 200,
                                                    child: ListView.builder(
                                                        itemCount: pizzaList[index].crustItems[i].crustSizes.length,
                                                        itemBuilder: (context, j) {
                                                          return ListTile(
                                                            title: Text(pizzaList[index].crustItems[i].crustSizes[j]),
                                                            trailing: Text(pizzaList[index].crustItems[i].crustCosts[j].toString()),
                                                          );
                                                        }),
                                                  ),
                                                ],
                                              );
                                              return ListTile(
                                                title: Text(pizzaList[index].crustItems[i].name),
                                              );
                                            }
                                        ),
                                      );
                                    });
                              }
                                );

                          },
                          child: const Text("Add to cart"),
                      ),
                    ],
                  ),
                ),
              );
            }
        )
      ),
    );
  }
  /*
  void showCustomDialog(PizzaDetails pizzaItem) async {
    debugPrint("In showCustomDialog");
    await AlertDialog(
      title: Text("Customise your pizza"),
      content: Container(
        height: 600,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(10),
              topRight: Radius.circular(10)),
        ),
        child: ListView.builder(
            itemCount: pizzaItem.crustItems.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(pizzaItem.crustItems.length.toString()),
              );
            }
            ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Approve'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
  */
}
