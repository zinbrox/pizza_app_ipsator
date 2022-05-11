import 'dart:convert';
import 'dart:math';

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

  //List of lists of added items. index 0= pizza name, index 1= pizza crust type, index 2= pizza crust size, index 3= pizza crust cost, index 4= quantity
  List cartDetails = [];

  //Status Code for the http request
  late int statusCode;
  late String statusMessage;

  //vble for loading widget until all details fetched
  bool _loading = true;

  //Total price of all the pizzas
  double price = 0.0;
  //Total quantity of all the pizzas
  int quantity = 0;

  int val=-1;


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

    //Calculate price of cart (will be empty here)
    _updatePriceQty();

    setState(() {
      _loading = false;
    });


    debugPrint(statusCode.toString());
  }

  //Function to calculate price and quantity of the cart
  void _updatePriceQty() {
    price = 0.0;
    quantity = 0;
    for(var item in cartDetails) {
      price += item[3] * item[4];
      quantity += item[4] as int;
    }
  }

  //Get default price of a given pizza
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
          backgroundColor: Colors.deepOrangeAccent,
          centerTitle: true,
        ),
      body: Center(
        child: _loading? const CircularProgressIndicator() : Column(
          children: [
            Expanded(
              child: SizedBox(
                height: MediaQuery.of(context).size.height*0.7,
                child: ListView.builder(
                  itemCount: pizzaList.length,
                    itemBuilder: (context, index) {
                      return InkWell(
                        onTap: () {
                          debugPrint("Pressed on Pizza");
                        },
                        child: Card(
                          elevation: 10,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          child: Column(
                            children: [
                              //Using a random pizza image
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: const Image(
                                  image: NetworkImage('https://www.simplyrecipes.com/thmb/48O78GUQ-HBoDZS4m1ty3pUZ-tg=/720x0/filters:no_upscale():max_bytes(150000):strip_icc():format(webp)/__opt__aboutcom__coeus__resources__content_migration__simply_recipes__uploads__2019__09__easy-pepperoni-pizza-lead-3-8f256746d649404baa36a44d271329bc.jpg'
                                  ),
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(pizzaList[index].name),
                                  const Spacer(),
                                  Icon(Icons.circle, color: pizzaList[index].isVeg? Colors.green : Colors.red.shade900,),
                                  Text(pizzaList[index].isVeg? "Veg" : "Non-Veg"),
                                ],
                              ),
                              const SizedBox(height: 10,),
                              Text(pizzaList[index].description),
                              Row(
                                children: [
                                  Text("₹" + getDefaultPrice(index).toString()),
                                  const Spacer(),
                                  ElevatedButton(
                                      onPressed: () async {
                                        debugPrint("Pressed Customise");
                                        showCustomDialog(index);
                                      },
                                      style: ElevatedButton.styleFrom(primary: Colors.green,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(30.0),
                                        ),
                                      ),
                                      child: const Text("Customise"),
                                  ),
                                  const SizedBox(width: 5,),
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
                  const SizedBox(width: 10,),
                  Text(quantity.toString() + " Item(s) "),
                  Text(" Price: " + price.toString()),
                  const Spacer(),
                  ElevatedButton(
                      onPressed: () {
                        debugPrint("Pressed View Cart");
                        viewCartDialog();
                      },
                      style: ElevatedButton.styleFrom(primary: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                      ),
                      child: const Text("View Cart"),
                  ),
                  const SizedBox(width: 10,),
                ],
              ),
            ),
          ],
        )
      ),
    );
  }

  //Function to show dialog to add custom pizzas
  void showCustomDialog(int index) async {
    debugPrint("In showCustomDialog");
    int defaultCrust = pizzaList[index].defaultCrust-1;
    String? selectedCrust = pizzaList[index].crustItems[defaultCrust].name;
    int selectedCrustIndex = defaultCrust;
    int selectedCrustSize = pizzaList[index].crustItems[defaultCrust].defaultSize-1;
    await showModalBottomSheet(
      isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  height: MediaQuery.of(context).size.height*0.7,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      //Commented out part is for dropdown menu with available crusts instead of showing all crusts directly
                      /*
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
                      */
                      //Show available crusts and change the crust sizes based on the chosen crust
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.3,
                        child: IntrinsicHeight(
                          child: ListView.builder(
                              itemCount: pizzaList[index].crustItems.length,
                              itemBuilder: (context, i) {
                                return ListTile(
                                  title: Text(pizzaList[index].crustItems[i].name),
                                  trailing: Radio(
                                    value: i,
                                    groupValue: defaultCrust,
                                    onChanged: (value) {
                                      debugPrint("Selected crust type");
                                      setState(() {
                                        defaultCrust = value as int;
                                        selectedCrustIndex = pizzaList[index].crustItems[defaultCrust].id - 1;
                                        selectedCrustSize = pizzaList[index].crustItems[defaultCrust].defaultSize - 1;
                                      });
                                    },
                                  ),
                                );
                              }
                          ),
                        ),
                      ),

                      //Show available crust sizes and price based on the crust type
                      SizedBox(
                        height: MediaQuery.of(context).size.height*0.3,
                        child: ListView.builder(
                          itemCount: pizzaList[index].crustItems[selectedCrustIndex].crustSizes.length,
                            itemBuilder: (context, i) {
                              return ListTile(
                                title: Text(pizzaList[index].crustItems[selectedCrustIndex].crustSizes[i]),
                                subtitle: Text("₹" + pizzaList[index].crustItems[selectedCrustIndex].crustCosts[i].toString()),
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

                      //Button to add the chosen crust type and size to the cart
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
                            _updatePriceQty();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text("Add to Cart"),
                      )
                    ],
                  ),
                );
              });
        }
    );
    setState(() {
    });
  }

  Future<void> viewCartDialog() async {
    debugPrint("In viewCartDialog()");
    _updatePriceQty();
    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (context, setState) {
                return Container(
                  height: MediaQuery.of(context).size.height*0.6,
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10)),
                  ),
                  child: Column(
                    children: [
                      cartDetails.isEmpty? const Text("Your cart is empty!") : SizedBox(
                        height: MediaQuery.of(context).size.height*0.4,
                        child: ListView.builder(
                          itemCount: cartDetails.length,
                            itemBuilder: (context, index) {
                              return Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    children: [
                                      Text(cartDetails[index][0]),
                                      Text(cartDetails[index][1]),
                                      Text(cartDetails[index][2]),
                                    ],
                                  ),
                                  const Spacer(),
                                  RawMaterialButton(
                                      fillColor: Colors.white,
                                      elevation: 2.0,
                                      shape: CircleBorder(),
                                      onPressed: () {
                                    debugPrint("Removed a Item");
                                    if(cartDetails[index][4] == 1) {
                                      cartDetails.removeAt(index);
                                    }
                                    else {
                                      cartDetails[index][4]--;
                                    }
                                    setState (() {
                                      _updatePriceQty();
                                    });
                                  }, child: const Icon(Icons.remove)),
                                  Text(cartDetails[index][4].toString()),
                                  RawMaterialButton(
                                    fillColor: Colors.white,
                                    elevation: 2.0,
                                    shape: CircleBorder(),
                                    onPressed: () {
                                    debugPrint("Added an Item");
                                    setState(() {
                                      cartDetails[index][4]++;
                                      _updatePriceQty();
                                    });
                                  }, child: const Icon(Icons.add),),
                                  Text((cartDetails[index][3] * cartDetails[index][4]).toString()),
                                  const SizedBox(width: 10,),
                                ],
                              );
                            }),
                      ),
                      const Spacer(),
                      Text("Total Quantity: " + quantity.toString()),
                      Text("Total Price: ₹" + price.toString()),
                      ElevatedButton(
                          onPressed: () {
                            debugPrint("Order Placed");
                          },
                          style: ElevatedButton.styleFrom(primary: Colors.deepOrangeAccent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text("Place Order")
                      ),
                    ],
                  ),
                );
              }
              );
        }
        );
    setState(() {
    });
  }

}
