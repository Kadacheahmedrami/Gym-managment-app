import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:hamza_gym/MainPage.dart';
import 'package:hamza_gym/addclient.dart';
import 'package:hamza_gym/animation.dart';
import 'package:hamza_gym/login.dart';


import 'package:hamza_gym/notify.dart';
import 'package:hamza_gym/stat.dart';
import 'package:hamza_gym/trainers.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';




Color gren = const Color(0xffEDFE10);
Color back = const Color(0xff1c2126);
Color shadow=  const Color(0xff2a3036);

class Client {
  final String id;
  final String name;
  final String gender;
  final String membershipType;
  final DateTime membershipExpiration;
  final DateTime registrationDate; // New field for registration date
  final int age;
  final String address;
  final String phone;
  final String email;
  final double balance;
  final String image_Path;

  Client({
    required this.id,
    required this.name,
    required this.gender,
    required this.membershipType,
    required this.membershipExpiration,
    required this.registrationDate, // New parameter for registration date
    required this.age,
    required this.address,
    required this.phone,
    required this.email,
    required this.balance,
    required this.image_Path
  });

  
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Initialize Firestore
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Configure Firestore settings
  firestore.settings = Settings(
    persistenceEnabled: false,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Flutter Demo',
      
      debugShowCheckedModeBanner: false,
      home: LoginPage(),
    
      
    
    );
  }
}


class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override



  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: const Icon(
        Icons.fitness_center, // Fitness icon
        size: 200, // Adjust icon size as needed
        color: Colors.white, // Icon color
      ),
      
      backgroundColor: Colors.black,// back,
      nextScreen: LoginPage(),
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
    );
  }
}



class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  _NavigationState createState() => _NavigationState();
}




class _NavigationState extends State<Navigation> {


  

    int _currentIndex = 0;

    void _onNavBarTapped(int index) {
    setState(() {
      _currentIndex = index;
  print('$index , $_currentIndex');
    });
  }
List<Client> clients = [];


void initState() {


  
    super.initState();
  FirebaseFirestore.instance
    .collection('clients')
    .get()
    .then((QuerySnapshot querySnapshot) {
      int birth_date ;
        querySnapshot.docs.forEach((doc) {
          if(doc['birth_date']=='')
          {
            birth_date=DateTime.now().year;
          }
          else{
       birth_date= DateTime.parse(doc['birth_date']).year;
          }
   
          setState(() {
            
            clients.add(
              Client(
                id:doc.id,
                name: doc['name'],
                gender: doc['gender'],
                 balance: double.parse(doc['balance']),
                 membershipType: doc['plan'],
                 address: doc['address'],
                 age: DateTime.now().year - birth_date,
                 email: doc['email'],
                 phone: doc['number'],
                 membershipExpiration: DateTime.parse(doc['exp_date']),
                 registrationDate: DateTime.parse(doc['reg_date']),
                 image_Path: doc['image_path']
                              )
            );
          });

        });
        print(clients);
    });

  }



 @override
  Widget build(BuildContext context) {



      List <Widget> pages = [
       MainPage(clients: clients), // Replace with your page widgets
       StatisticsPage(clients: clients),
   
       Stack(
          alignment: Alignment.center,
          children: [
            SvgPicture.asset(
              'assets/images/dumbels.svg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover, // Ensure the SVG covers the entire background
            ),
            Container(
              margin: EdgeInsets.only(top: 500),
              child:   Text('Made by Kadache',style: TextStyle(fontSize: 30,color: Colors.white70),) ,
            ),
                 Container(
              margin: EdgeInsets.only(top: 508,right: 5), 
              child:   Text('Made by Kadache',style: TextStyle(fontSize: 30,color: Colors.white30),) ,
            ),
         
            // Shadow layer
            Positioned(
              child: SvgPicture.asset(
                'assets/images/logo.svg',
                semanticsLabel: 'Logo',
                height: 380.0, // Adjust size as needed
                color: gren.withOpacity(0.6),
                 // Apply the glow color with opacity
              ),
            ),
            // Original logo layer
            SvgPicture.asset(
              'assets/images/logo.svg',
              semanticsLabel: 'Logo',


              height: 350.0, // Adjust size as needed
            ),
          ],
        ),
      
     TrainerPage(  trainers: [
        Trainer(name: 'John Doe', specialty: 'Strength Training'),
        Trainer(name: 'Jane Smith', specialty: 'Yoga'),
        Trainer(name: 'Michael Johnson', specialty: 'Cardio'),
      ])
  
    ];




  return Scaffold(
      
       appBar: AppBar(
      
        centerTitle: true,
        backgroundColor: back,
        foregroundColor: Colors.white ,
        title: const Text('Gym Management App'),
        actions: [
          IconButton(
         
            icon: const Icon(Icons.notifications),
            onPressed: () {
          Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => NotificationPage(
      clients:clients
    ),
  ),
);

            },
          ),
        ],
      ),
      body: pages.elementAt(_currentIndex),
  backgroundColor: back,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(

        ),
        notchMargin: 8,
      color: const Color(0xff2A3036),
       // Nav bar color
        child:
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children:   [
        
              Ink(
              width: 50,
              height: 60,
              child:      InkWell(
          
          onTap : (){_onNavBarTapped(0);},          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
           Icon(Icons.person, color:_currentIndex!=0 ? Colors.white : gren,size: 36,),Text("Clients",style: TextStyle( color:_currentIndex!=0 ? Colors.white : gren))
            ],
          ),
           
          ),
            ),
                Ink(
              width: 50,
              height: 60,
              child:    InkWell(
          
          onTap : (){_onNavBarTapped(1);},          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
             Icon(Icons.list_alt, color:_currentIndex!=1 ? Colors.white : gren, size: 36,),Text("stats",style: TextStyle( color:_currentIndex!=1 ? Colors.white : gren) )          ],
          ),
   
          ), 
            ),
              Ink(
              width: 54,
              height: 60,
              child:     
   
        InkWell(
          
          onTap : (){_onNavBarTapped(2);},          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.logo_dev_outlined,  color:_currentIndex!=2 ? Colors.white : gren,size: 36,),Text('Credit',style: TextStyle( color:_currentIndex!=2 ? Colors.white : gren))
            ],
          ),
           
           
          ),
            ),
              Ink(
              width: 53,
              height: 60,
              child:  InkWell(
          
          
          onTap : (){_onNavBarTapped(3);},          
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Icon(Icons.sports_gymnastics_rounded, color:_currentIndex!=3 ? Colors.white : gren,size: 36,),Text('Trainers',style: TextStyle( color:_currentIndex!=3 ? Colors.white : gren))
            ],
          ),
          
          ),
            ),

       
        ],
        )
      
      ),
      floatingActionButton: 
      SizedBox(
        height: 65,
        width: 65,
        child:     FloatingActionButton(
            onPressed: () {
             Navigator.push(context , MaterialPageRoute(builder: (context){return MembershipFormPage();}));
            }, // Adjust icon size as needed
            backgroundColor: gren,
            elevation: 0, // shadow for better visibility
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50), // Adjust to create a circular button
            ),
            
            child: Icon(Icons.add, size: 50,color: back,),
          ),
      ),
      
          
     floatingActionButtonLocation:FloatingActionButtonLocation.centerDocked 
        
    );
  }
}
