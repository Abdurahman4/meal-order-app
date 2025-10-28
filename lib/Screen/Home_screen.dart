import 'package:e_commerce/Screen/LoginScreen.dart';
import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../Screen/Orders_screen.dart';
import '../Screen/CartScreen.dart';
import 'package:badges/badges.dart' as badges;
import 'globals.dart' as globals;

class Meal {
  final String name;
  final String imagePath;
  final double price;

  Meal({required this.name, required this.imagePath, required this.price});
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int cartCount = 0;

  final List<Meal> meals = [
    Meal(
        name: 'Beef Burger',
        imagePath: 'images/Beef_Burger.PNG',
        price: 30.0000),
    Meal(
        name: 'Classic Chicken Burger',
        imagePath: 'images/Classic_Chicken_Burger.PNG',
        price: 28.0),
    Meal(
        name: 'Chicken Arabi',
        imagePath: 'images/Chicken_Arabi.PNG',
        price: 24.0),
    Meal(
        name: 'Crispy Burger',
        imagePath: 'images/Crispy_Burger.PNG',
        price: 32.0),
    Meal(
        name: 'Meat Sandwich',
        imagePath: 'images/Meat_Sandwich.PNG',
        price: 26.0),
  ];
  int quantity = 1;
  void _showOrderDialog(BuildContext context, Meal meal) {
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) {
        int localQuantity = quantity;

        return StatefulBuilder(
          builder: (context, dialogSetState) {
            return AlertDialog(
              title: Text('Order: ${meal.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Do you want to customize',
                    style: TextStyle(fontSize: 10),
                  ),
                  TextField(
                    controller: notesController,
                    decoration: const InputDecoration(
                        hintText: 'like: without mayyounaize'),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Quantity:'),
                      DropdownButton<int>(
                        value: localQuantity,
                        items: List.generate(10, (index) => index + 1)
                            .map((q) => DropdownMenuItem<int>(
                                  value: q,
                                  child: Text('$q'),
                                ))
                            .toList(),
                        onChanged: (value) {
                          dialogSetState(() {
                            localQuantity = value!;
                          });
                        },
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    cart.add(CartItem(
                      mealName: meal.name,
                      quantity: localQuantity,
                      notes: notesController.text,
                      price: meal.price,
                    ));

                    Navigator.pop(context);

                    setState(() {
                      cartCount = cart.length;
                    });

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Added to cart!')),
                    );
                  },
                  child: const Text('Add to Cart'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Menu'),
        actions: [
          Text("Hello ${globals.currentUsername ?? "Username"}"),
          IconButton(
            icon: const Icon(Icons.list_alt),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const OrdersScreen()),
              );
            },
          ),
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: badges.Badge(
              position: badges.BadgePosition.topEnd(top: 0, end: 0),
              showBadge: cartCount > 0,
              badgeContent: Text(
                '$cartCount',
                style: const TextStyle(color: Colors.white),
              ),
              child: IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  ).then((_) {
                    setState(() {
                      cartCount = cart.length; // تحديث العدد بعد الرجوع
                    });
                  });
                },
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: meals.length,
        itemBuilder: (context, index) {
          final meal = meals[index];
          return Card(
            elevation: 4,
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(18),
                    topRight: Radius.circular(18),
                  ),
                  child: Image.asset(
                    meal.imagePath,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            meal.name,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${meal.price.toStringAsFixed(0)} SAR',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: () => _showOrderDialog(context, meal),
                        icon: const Icon(Icons.add),
                        label: const Text('Order'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
