import 'package:flutter/material.dart';
import '../db_helper.dart';
import '../Screen/globals.dart' as globals;
import '../Screen/PaymentScreen.dart';

class CartItem {
  final String mealName;
  int quantity;
  final String notes;
  final double price;

  CartItem({
    required this.mealName,
    required this.quantity,
    required this.notes,
    required this.price,
  });
}

List<CartItem> cart = [];

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  int gettotalItem() {
    int totalitam = 0;
    for (var item in cart) {
      totalitam += item.quantity;
    }
    return totalitam;
  }

  double getTotalPrice() {
    double total = 0;
    for (var item in cart) {
      total += item.quantity * item.price;
    }
    return total;
  }

  void confirmOrders() async {
    final db = await DBHelper.database;

    for (var item in cart) {
      await db.insert("orders", {
        'userId': globals.currentUserId,
        'mealName': item.mealName,
        'notes': item.notes,
        'status': 'new',
        'dateTime': DateTime.now().toString(),
        'quantity': item.quantity,
      });
    }
    setState(() {
      cart.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All order have been confirmed')),
    );
  }

  int cartcount = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: cart.isEmpty
          ? const Center(child: Text('Cart is Empty'))
          : Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    itemCount: cart.length,
                    itemBuilder: (context, index) {
                      final item = cart[index];
                      return ListTile(
                        title: Text(item.mealName), // 👈 اسم الوجبة فقط
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (item.notes.isNotEmpty)
                              Text(item.notes), // 👈 ملاحظات إذا في
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove),
                                  onPressed: () {
                                    setState(() {
                                      if (item.quantity > 1) {
                                        item.quantity -= 1;
                                      } else {
                                        cart.removeAt(index); // حذف إذا صار 0
                                      }
                                    });
                                  },
                                ),
                                Text('${item.quantity}'),
                                IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      item.quantity += 1;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext contex) {
                                  return AlertDialog(
                                    title: const Text("Confirm deletion"),
                                    content: const Text(
                                        "do you want to delete this order from a cart"),
                                    actions: [
                                      TextButton(
                                        child: const Text("Cancel"),
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                      ),
                                      TextButton(
                                        child: const Text("حذف"),
                                        onPressed: () {
                                          setState(() {
                                            cart.removeAt(index);
                                          });
                                          Navigator.of(context)
                                              .pop(); // يغلق الـ Dialog بعد الحذف
                                        },
                                      ),
                                    ],
                                  );
                                });
                            setState(() {
                              cart.removeAt(index);
                              cartcount = cart.length;
                            });
                          },
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total (${gettotalItem()} items):',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${getTotalPrice().toStringAsFixed(2)} SAR',
                        style:
                            const TextStyle(fontSize: 18, color: Colors.teal),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: ElevatedButton(
                    onPressed: () async {
                      // روح على صفحة الدفع
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const PaymentScreen()),
                      );

                      // إذا رجعت النتيجة "success" → نفذ confirmOrders()
                      if (result == "success") {
                        confirmOrders();
                      }
                    },
                    child: const Text('Proceed to Payment'),
                  ),
                ),
              ],
            ),
    );
  }
}
