import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:hamza_gym/login.dart';

import 'main.dart';

class CustomDrawer extends StatelessWidget {
  
   final email;
  final password;
  final bool? fix;
  const CustomDrawer({required  this.email , required this.password,this.fix,super.key});
  @override
  Widget build(BuildContext context) {
    return 
   Container(
    width: 300,
        decoration: BoxDecoration(
          gradient:theme ? LinearGradient(
            colors: [Colors.white, Color(0xffe0e0e0), Color(0xffc8c8c8)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) :LinearGradient(
            colors: [Colors.black, Color(0xff1d1e22), Color(0xff393f4d)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) ,
        ),

        child: Column(
          children: <Widget>[
            // Drawer Header
            DrawerHeader(
              decoration: BoxDecoration(
              boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5), // Color of the shadow
        spreadRadius: 2, // The amount of space the shadow will spread
        blurRadius: 5, // The amount of blur applied to the shadow
        offset: Offset(0, 2), // The offset of the shadow (dx, dy)
      ),
    ],
                gradient: LinearGradient(
                  colors: [Color(0xfff2f2f2),theme ? Colors.white: shadow],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(

                    radius: 40,
                    backgroundColor:theme ? Colors.grey[300] : shadow,
                    child: Icon(
                      Icons.person,
                      size: 50,
                      color:theme ? Colors.black : Colors .white,
                    ),
                    
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Menu',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                 
                ],
              ),
            ),
           Text('$email'),
          
            _buildDrawerItem(Icons.exit_to_app, 'exit', context),
          
            Spacer(),
            // Footer Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Kadache Ahmed Rami',
                    style: TextStyle(
                      color: theme ? Colors.black87 :Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Version 1.3.0',
                    style: TextStyle(
                      color:theme ? Colors.black54 : Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        
      ),
    );
  }

  Widget _buildDrawerItem(IconData icon, String text, BuildContext context) {
    return ListTile(
      leading: Icon(icon, color:theme ? Colors.black :Colors.white),
      title: Text(text, style: TextStyle(color:theme ? Colors.black :Colors.white)),
onTap: () async {
  await FirebaseAuth.instance.signOut();

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => LoginPage()),
    (Route<dynamic> route) => false,  // This removes all the previous routes
  );
},

    );
  }
}


