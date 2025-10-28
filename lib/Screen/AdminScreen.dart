import 'package:e_commerce/Screen/LoginScreen.dart';
import '../UsersScreen.dart';
import 'package:flutter/material.dart';
import '../db_helper.dart';

class AdminScreen extends StatefulWidget {
  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  Map<String, List<Map<String, dynamic>>> groupedOrders = {};

  @override
  void initState() {
    super.initState();
    fetchOrders();
  }

  Future<void> fetchOrders() async {
    final orders = await DBHelper.getAllOrdersWithUsers();
    setState(() {
      groupedOrders.clear();
      for (var order in orders) {
        String customer = order['username'] ?? 'Unknown';
        if (!groupedOrders.containsKey(customer)) {
          groupedOrders[customer] = [];
        }
        groupedOrders[customer]!.add(order);
      }
    });
  }

  Future<void> updateStatus(int orderId, String newStatus) async {
    await DBHelper.updateOrderStatus(orderId, newStatus);
    fetchOrders();
  }

  bool showOrders = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        leading: IconButton(
          icon: Icon(Icons.logout),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => const LoginScreen()),
            );
          },
        ),
      ),

      // 🚀 تعديل: غيرت من ListView → SingleChildScrollView + Column
      // السبب: كان عندك ListView جوّا ListView وبيسبب خطأ RenderBox
      body: SingleChildScrollView(
        padding: EdgeInsets.all(12),
        child: showOrders
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Customer Orders",
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  groupedOrders.isEmpty
                      ? Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Text('No orders found'),
                          ),
                        )
                      : Column(
                          children: groupedOrders.entries.map((entry) {
                            String customer = entry.key;
                            List<Map<String, dynamic>> orders = entry.value;

                            return Card(
                              margin: EdgeInsets.symmetric(vertical: 6),
                              child: ExpansionTile(
                                title: Text("Customer: $customer",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                children: orders.map((order) {
                                  return ListTile(
                                    title: Text("Meal: ${order['mealName']}"),
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text("Quantity: ${order['quantity']}"),
                                        Text("Status: ${order['status']}"),
                                        DropdownButton<String>(
                                          value: order['status'],
                                          isExpanded: true,
                                          items: [
                                            'new',
                                            'processing',
                                            'complete'
                                          ].map((status) {
                                            return DropdownMenuItem<String>(
                                              value: status,
                                              child: Text(status),
                                            );
                                          }).toList(),
                                          onChanged: (newStatus) {
                                            if (newStatus != null) {
                                              updateStatus(
                                                  order['id'], newStatus);
                                            }
                                          },
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            );
                          }).toList(),
                        ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        showOrders = false; // رجوع للداشبورد
                      });
                    },
                    child: Text("Back to Dashboard"),
                  ),
                ],
              )
            : GridView.count(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _buildDashboardCard(
                    context,
                    title: "Manage Users",
                    subtitle: "View all registered users",
                    icon: Icons.people,
                    color: Colors.blue,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => UsersScreen()),
                      );
                    },
                  ),
                  _buildDashboardCard(
                    context,
                    title: "View Orders",
                    subtitle: "Check all customer orders",
                    icon: Icons.receipt_long,
                    color: Colors.green,
                    onTap: () {
                      setState(() {
                        showOrders = true; // ✅ نعرض الطلبات بدل الداشبورد
                      });
                    },
                  ),
                ],
              ),
      ),
    );
  }

  // 🔹 Widget خاص بالكروت
  Widget _buildDashboardCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Card(
        color: color.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Container(
          height: 180,
          padding: EdgeInsets.all(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: color),
              Spacer(),
              Text(title,
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold, color: color)),
              SizedBox(height: 4),
              Text(subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.black54)),
            ],
          ),
        ),
      ),
    );
  }

  // مفتاح عشان ننزل للطلبات
  final ordersKey = GlobalKey();
}
