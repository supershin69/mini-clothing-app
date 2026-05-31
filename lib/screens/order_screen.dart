import 'package:flutter/material.dart';

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Order History Data
    final List<Map<String, dynamic>> orders = [
      {'id': '#00124', 'date': '12 May 2026', 'amount': '25,000 MMK', 'status': 'Delivered'},
      {'id': '#00115', 'date': '05 May 2026', 'amount': '15,000 MMK', 'status': 'Delivered'},
      {'id': '#00102', 'date': '28 April 2026', 'amount': '45,000 MMK', 'status': 'Pending'},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Orders', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Theme.of(context).primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView.builder(
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
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.1), 
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.shopping_bag, color: Theme.of(context).primaryColor),
                ),
                title: Text('Order ${order['id']}', style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Ordered on: ${order['date']}'),
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(order['amount'], style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor)),
                    const SizedBox(height: 4),
                    Text(
                      order['status'],
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.bold,
                        color: order['status'] == 'Pending' ? Colors.orange : Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}