import 'package:flutter/material.dart';
import '../db_helper.dart';
import 'Home_screen.dart';
import '../Screen/globals.dart' as globals;

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  String selectedStatus = 'all'; // القيمة الافتراضية "الكل"

  List<String> statuses = ['all', 'new', 'processing', 'complete'];

  Future<List<Map<String, dynamic>>> fetchOrders() async {
    final db = await DBHelper.database;

    if (selectedStatus == 'all') {
      return await db.query('orders',
          where: 'userId = ?',
          whereArgs: [globals.currentUserId],
          orderBy: 'dateTime DESC');
    } else {
      return await db.query(
        'orders',
        where: 'status = ? AND userId = ?',
        whereArgs: [selectedStatus, globals.currentUserId],
        orderBy: 'dateTime DESC',
      );
    }
  }

  Color getStatusColor(String status) {
    switch (status) {
      case 'new':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'complete':
        return Colors.green;
      default:
        return Colors.black;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // يرجع للشاشة السابقة
          },
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: DropdownButton<String>(
              value: selectedStatus,
              items: statuses.map((status) {
                return DropdownMenuItem<String>(
                  value: status,
                  child: Text(
                    status == 'all'
                        ? 'All'
                        : status == 'new'
                            ? 'New'
                            : status == 'processing'
                                ? 'Processing'
                                : 'Completed',
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedStatus = value!;
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder(
              future: fetchOrders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('There is no orders'),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(builder: (_) => HomeScreen()),
                          );
                        },
                        child: const Text('Go to add order'),
                      )
                    ],
                  );
                }

                final orders = snapshot.data!;
                return ListView.builder(
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        title:
                            Text('${order['mealName']} × ${order['quantity']}'),
                        subtitle:
                            Text('${order['notes']}\n${order['dateTime']}'),
                        trailing: Text(
                          order['status'],
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: getStatusColor(order['status']),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
