import 'package:flutter/material.dart';
import '../db_helper.dart';

class UsersScreen extends StatelessWidget {
  const UsersScreen({super.key});
  @override
  Widget build(BuildContext contex) {
    return Scaffold(
      appBar: AppBar(
        title: Text("All Users"),
      ),
      body: FutureBuilder(
          future: DBHelper.getAllUsers(),
          builder: (contex, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text("No Users Found"),
              );
            }
            final users = snapshot.data!;
            return ListView.builder(
              itemCount: users.length,
              itemBuilder: (contex, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text("Username: ${user['username']}"),
                  subtitle: Text('Password: ${user['password']}'),
                );
              },
            );
          }),
    );
  }
}
