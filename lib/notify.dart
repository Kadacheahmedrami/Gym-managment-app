import 'package:flutter/material.dart';
import 'package:hamza_gym/Client.dart';

import 'package:hamza_gym/main.dart';
import 'package:hamza_gym/trainers.dart';
import 'package:intl/intl.dart';



class NotificationPage extends StatelessWidget {
  final List<Client> clients;
  final List<Plan> plans;
  NotificationPage({required this.clients,required this.plans});

  @override
  Widget build(BuildContext context) {
    final expiredClients = clients.where((client) {
      return client.membershipExpiration.isBefore(
        DateTime.now().add(Duration(days: 0)).subtract(Duration(
          hours: DateTime.now().hour,
          minutes: DateTime.now().minute,
          seconds: DateTime.now().second,
          milliseconds: DateTime.now().millisecond,
          microseconds: DateTime.now().microsecond,
        )),
      );
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Expired Memberships', style: TextStyle(color: gren)),
        backgroundColor: back,
         foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: expiredClients.length,
        itemBuilder: (context, index) {
          final client = expiredClients[index];
          return Card(
            color: shadow,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                client.name,
                style: TextStyle(color: gren, fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Expired on: ${DateFormat.yMMMd().format(client.membershipExpiration)}',
                style: TextStyle(color: Colors.white70),
              ),
              trailing: Icon(Icons.warning, color: Colors.red),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProfilePage(client: client,plans: plans,),
                  ),
                );
              },
            ),
          );
        },
      ),
      backgroundColor: back,
    );
  }
}
