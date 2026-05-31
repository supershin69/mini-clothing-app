
import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Order History Mock Data
    final List<Map<String, dynamic>> orders = [
      {'id': '#00124', 'date': '12 May 2026', 'amount': '25,000 MMK', 'status': 'Delivered'},
      {'id': '#00115', 'date': '05 May 2026', 'amount': '15,000 MMK', 'status': 'Delivered'},
      {'id': '#00102', 'date': '28 April 2026', 'amount': '45,000 MMK', 'status': 'Pending'},
    ];

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header Profile Container
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: const BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: const Column(
                children: [
                  CircleAvatar(
                    radius: 55,
                    backgroundImage: NetworkImage('https://api.dicebear.com/7.x/avataaars/png?seed=Felix'),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Thue Htet Naing',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
                  ),
                  Text('thuehtet@email.com', style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Order History Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Order History', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),

                  // Order List Cards
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(15),
                          leading: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                            child: const Icon(Icons.shopping_bag, color: Colors.blue),
                          ),
                          title: Text('Order ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Ordered on: ${order['date']}'),
                          trailing: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(order['amount'], style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                              Text(
                                order['status'],
                                style: TextStyle(fontSize: 12, color: order['status'] == 'Pending' ? Colors.orange : Colors.green),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 10),
                  
                  // Logout Button Widget
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      onTap: () => print('User Logged out'),
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: const Text('Logout', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}