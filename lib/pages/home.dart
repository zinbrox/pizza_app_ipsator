import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

//class to store Crust details (type, size and cost)
class CrustDetails {
  int id, defaultSize;
  String name;
  List crustSizes, crustCosts;

  CrustDetails({required this.id, required this.defaultSize, required this.name, required this.crustSizes, required this.crustCosts});
}

//class to store Pizza details
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

  //List of the custom PizzaDetails objects
  List<PizzaDetails> pizzaList = [];

  List cartDetails = [];

  //Status Code for the http request
  late int statusCode;
  late String statusMessage;

  bool _loading = true;

  int val=-1;
  bool _value=false;

  //Function to get Pizza details for http GET request
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
      int id, defaultSize;

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
          defaultSize = crust['defaultSize'];
          crustSizes.clear();
          crustCosts.clear();
          for(var sizes in crust['sizes']) {
            //crustSizes[sizes['name']] = sizes['price'];
            crustSizes.add(sizes['name']);
            crustCosts.add(sizes['price']);

          }
          crustItem = CrustDetails(id: id, defaultSize: defaultSize, name: crustName, crustSizes: crustSizes.toList(), crustCosts: crustCosts.toList());
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

  int getDefaultPrice(int index) {
    int defaultCrust = pizzaList[index].defaultCrust;
    int defaultSize = pizzaList[index].crustItems[defaultCrust-1].defaultSize;
    return pizzaList[index].crustItems[defaultCrust-1].crustCosts[defaultSize-1];
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
        child: _loading? const CircularProgressIndicator() : Column(
          children: [
            Expanded(
              child: Container(
                child: ListView.builder(
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
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(pizzaList[index].name),
                                  Text(pizzaList[index].isVeg? "Veg" : "Non-Veg"),
                                ],
                              ),
                              Text(pizzaList[index].description),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("₹" + getDefaultPrice(index).toString()),
                                  ElevatedButton(
                                      onPressed: () async {
                                        debugPrint("Pressed Customise");
                                        showCustomDialog(index);
                                      },
                                      child: const Text("Customise"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                ),
              ),
            ),
            SizedBox(
              height: 100,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("1 Item"),
                  Text("500"),
                  ElevatedButton(
                      onPressed: () {
                        debugPrint("Pressed View Cart");
                        viewCartDialog();
                      },
                      child: const Text("View Cart"),
                  ),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  void showCustomDialog(int index) async {
    debugPrint("In showCustomDialog");
    int defaultCrust = pizzaList[index].defaultCrust-1;
    String? selectedCrust = pizzaList[index].crustItems[defaultCrust].name;
    int selectedCrustIndex = defaultCrust;
    int selectedCrustSize = pizzaList[index].crustItems[defaultCrust].defaultSize-1;
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
                  child: Column(
                    children: [
                      DropdownButton(
                        value: selectedCrust,
                        items: pizzaList[index].crustItems
                            .map<DropdownMenuItem<String>>((CrustDetails crust) {
                          return DropdownMenuItem<String>(
                            value: crust.name,
                            child: Text(crust.name),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedCrust = newValue;
                            for(var crust in pizzaList[index].crustItems) {
                              if (crust.name == selectedCrust) {
                                selectedCrustIndex = crust.id - 1;
                                selectedCrustSize = crust.defaultSize - 1;
                              }
                            }
                          });
                        },
                      ),
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: pizzaList[index].crustItems[selectedCrustIndex].crustSizes.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(pizzaList[index].crustItems[selectedCrustIndex].crustSizes[i]),
                                /*Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(pizzaList[index].crustItems[selectedCrustIndex].crustSizes[i]),
                                    Text(pizzaList[index].crustItems[selectedCrustIndex].crustCosts[i].toString()),
                                  ],
                                ),

                                 */
                                trailing: Radio(
                                  value: i,
                                  groupValue: selectedCrustSize,
                                  onChanged: (value) {
                                    debugPrint("Changed selection");
                                    setState((){
                                      selectedCrustSize = value as int;
                                    });
                                  },
                                ),
                              );
                            }
                        ),
                      ),
                      ElevatedButton(
                          onPressed: () {
                            debugPrint("Pressed Add to Cart");
                            bool checkExists = false;
                            for(var item in cartDetails) {
                              if(item[0] == pizzaList[index].name && item[1] == pizzaList[index].crustItems[selectedCrustIndex].name
                                  && item[2] == pizzaList[index].crustItems[selectedCrustIndex].crustSizes[selectedCrustSize]) {
                                item[4]++;
                                checkExists = true;
                              }
                            }
                            if(!checkExists) {
                              cartDetails.add([pizzaList[index].name,
                                pizzaList[index].crustItems[selectedCrustIndex].name,
                                pizzaList[index].crustItems[selectedCrustIndex].crustSizes[selectedCrustSize],
                                pizzaList[index].crustItems[selectedCrustIndex].crustCosts[selectedCrustSize],
                                1]);
                            }
                          },
                          child: const Text("Add to Cart"),
                      )
                    ],
                  ),
                );
              });
        }
    );
  }

  Future<void> viewCartDialog() async {
    debugPrint("In viewCartDialog()");
    double price = 0.0;
    for(var item in cartDetails) {
      price += item[3] * item[4];
    }
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
                  child: Column(
                    children: [
                      SizedBox(
                        height: 300,
                        child: ListView.builder(
                          itemCount: cartDetails.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      children: [
                                        Text(cartDetails[index][0]),
                                        Text(cartDetails[index][1]),
                                        Text(cartDetails[index][2]),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(onPressed: () {
                                    debugPrint("Removed a Item");
                                    if(cartDetails[index][4] == 1) {
                                      cartDetails.removeAt(index);
                                    }
                                    else {
                                      cartDetails[index][4]--;
                                    }
                                    setState (() {
                                      price=0;
                                      for(var item in cartDetails) {
                                        price += item[3] * item[4];
                                      }
                                    });
                                  }, icon: const Icon(Icons.remove)),
                                  Text(cartDetails[index][4].toString()),
                                  IconButton(onPressed: () {
                                    debugPrint("Added an Item");
                                    setState(() {
                                      cartDetails[index][4]++;
                                      price=0;
                                      for(var item in cartDetails) {
                                        price += item[3] * item[4];
                                      }
                                    });
                                  }, icon: const Icon(Icons.add),),
                                  Text((cartDetails[index][3] * cartDetails[index][4]).toString()),
                                ],
                              );
                            }),
                      ),
                      Text("Total Price: " + price.toString()),
                    ],
                  ),
                );
              }
              );
        }
        );
  }

}
