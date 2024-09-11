import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
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
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:page_transition/page_transition.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'local.dart';




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
  late final String image_Path;

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

  await Hive.initFlutter();
  Hive.registerAdapter(UserAdapter());
  Hive.registerAdapter(MembershipAdapter());
  await Hive.openBox<User>('clients');
  await Hive.openBox<Membership>('membershipBox');

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
  final bool? fix; // Optional boolean parameter

  const Navigation({Key? key, this.fix}) : super(key: key);

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

    StreamSubscription? _internetConnectionStreamSubscription;

     bool isConnectedToInternet =false;

     bool connectionChanged = false;
    bool usedOnce = true;

    void refresher() async {
      var clientBox = Hive.box<User>('clients');
      List<User> users = clientBox.values.toList();

      for (var usr in users) {
        if (usr.operation == 1) {
          DocumentReference docRef = await addUser(
            usr.name,
            usr.phone,
            usr.membershipType,
            'not yet', // fix this
            usr.balance.toString(),
            usr.registrationDate,
            usr.gender,
            usr.email,
            '',
            usr.address,
            usr.membershipExpiration,
            usr.image_Path,
          );

          // Update the operation field to 0
          usr.operation = 0;
          usr.id= docRef.id;

          // Save the updated user back to the box
          usr.save();
        }
        else{
          if(usr.operation == -1){
            String id= usr.id;
            await FirebaseFirestore.instance.collection('clients').doc(id).delete();
            usr.delete();
          }
          if(usr.operation== 2){

            Map<String, dynamic> userMap = {
              'address': usr.address ?? "",
              'balance': usr.balance.toString(),
              'birth_date': "", // Add birth_date from usr if available
              'email': usr.email ?? "",
              'exp_date': usr.membershipExpiration ?? "",
              'gender': usr.gender ?? "",
              'image_path': usr.image_Path ?? "none",
              'name': usr.name ?? "",
              'number': usr.phone ?? "",
              'paidAmount': "not yet", // Adjust according to your logic
              'plan': usr.membershipType ?? "1 month",
              'reg_date': usr.registrationDate ?? "",
            };

            // Update the user document in Firestore
            await FirebaseFirestore.instance.collection('clients').doc(usr.id).set(userMap);
            usr.operation= 0;
            usr.save();
          }
        }
      }
    }
    List<Plan> abonment=[] ;

    List<Plan> recoverPlans() {
      List<Plan> programs = [];

      var membershipBox = Hive.box<Membership>('membershipBox');
      List<Membership> memberships = membershipBox.values.toList();
      for(Membership mm in memberships){
        programs.add(Plan(name: mm.name, duration: mm.duration, price: mm.price));
      }
      return programs;
    }

    void _initializePlans()  {
      List<Plan> localPlans = recoverPlans();

      setState(() {
        // Update your state with the recovered plans
        for(Plan pp in localPlans){
          abonment.add(pp);
          print(pp.name);
        }
      });


    }

    void initState() {
      super.initState();




setState(() {
  _initializePlans();

});







      _internetConnectionStreamSubscription =
          InternetConnection().onStatusChange.listen((event) {


            switch (event) {
              case InternetStatus.connected:
                setState(() {
                  refresher();
                  print('case 1');
                  isConnectedToInternet = true;
                  connectionChanged=true;
                  if(usedOnce && widget.fix == false )
                    {
                      usedOnce= false;
                      loadData();
                    }


                });
                break;
              case InternetStatus.disconnected:
                setState(() {
                  print('case 2');
                  isConnectedToInternet = false;
                  connectionChanged=true;
                  if(usedOnce && widget.fix == false )
                  {
                    usedOnce= false;
                    loadData();
                  }

                });
                break;
              default:
                setState(() {
                  print('case 3');
                  isConnectedToInternet = false;
                  connectionChanged=true;
                  if(usedOnce && widget.fix == false )
                  {
                    usedOnce= false;
                    loadData();
                  }

                });
                break;
            }
          });

    if(widget.fix == true ){
      print("damn again  === ${widget.fix}");
      loadData();

    }

    }

    @override
    void dispose() {
      _internetConnectionStreamSubscription?.cancel();
      super.dispose();
    }

    void RefreshwithOnlineBase(clientBox){
      FirebaseFirestore.instance
          .collection('clients')
          .get()
          .then((QuerySnapshot querySnapshot) async {
        int birthDate;

        // Clear the local storage before syncing new data

        await clientBox.clear();

        querySnapshot.docs.forEach((doc) {
          if (doc['birth_date'] == '') {
            birthDate = DateTime.now().year;
          } else {
            birthDate = DateTime.parse(doc['birth_date']).year;
          }

          Client client = Client(
            id: doc.id,
            name: doc['name'],
            gender: doc['gender'],
            balance: double.parse(doc['balance']),
            membershipType: doc['plan'],
            address: doc['address'],
            age: DateTime.now().year - birthDate,
            email: doc['email'],
            phone: doc['number'],
            membershipExpiration: DateTime.parse(doc['exp_date']),
            registrationDate: DateTime.parse(doc['reg_date']),
            image_Path: doc['image_path'],
          );


          clientBox.put(doc.id, User(
              id: doc.id,
              name: doc['name'],
              gender: doc['gender'],
              membershipType: doc['plan'],
              membershipExpiration: doc['exp_date'],
              registrationDate: doc['reg_date'],
              age: DateTime.now().year - birthDate,
              address: doc['address'],
              phone: doc['number'],
              email: doc['email'],
              balance: double.parse(doc['balance']),
              image_Path: doc['image_path'],
              operation: 0
          ));





        });

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => Draweranimation(
              email: '',
              password: '',
              fix: true,
            ),
          ),
        );



      });

    }



    void OnlineBase(clientBox){
      FirebaseFirestore.instance
          .collection('clients')
          .get()
          .then((QuerySnapshot querySnapshot) async {
        int birthDate;

        // Clear the local storage before syncing new data

        await clientBox.clear();

        querySnapshot.docs.forEach((doc) {
          if (doc['birth_date'] == '') {
            birthDate = DateTime.now().year;
          } else {
            birthDate = DateTime.parse(doc['birth_date']).year;
          }

          Client client = Client(
            id: doc.id,
            name: doc['name'],
            gender: doc['gender'],
            balance: double.parse(doc['balance']),
            membershipType: doc['plan'],
            address: doc['address'],
            age: DateTime.now().year - birthDate,
            email: doc['email'],
            phone: doc['number'],
            membershipExpiration: DateTime.parse(doc['exp_date']),
            registrationDate: DateTime.parse(doc['reg_date']),
            image_Path: doc['image_path'],
          );


          clientBox.put(doc.id, User(
              id: doc.id,
              name: doc['name'],
              gender: doc['gender'],
              membershipType: doc['plan'],
              membershipExpiration: doc['exp_date'],
              registrationDate: doc['reg_date'],
              age: DateTime.now().year - birthDate,
              address: doc['address'],
              phone: doc['number'],
              email: doc['email'],
              balance: double.parse(doc['balance']),
              image_Path: doc['image_path'],
              operation: 0
          ));


          setState(() {
            clients.add(client);
          });


        });





      });
    }
    Future<void> loadData() async {

      print('stats   =============  $isConnectedToInternet');
      if (isConnectedToInternet) {
        var clientBox = Hive.box<User>('clients');

        if(clientBox.isEmpty)
          {
            // Load from Firestore
            print("hive box is empty");
          OnlineBase(clientBox);
          }
            else
              {
                print("hive box is Not empty");

                setState(() {
                  List<User> users=[];
                  users = clientBox.values.toList();
                  for (var usr in users){
                    print("${usr.name} has an operation of type ${usr.operation}");
                    if(usr.operation != -1){
                      Client client = Client(
                        id: usr.id,
                        name: usr.name,
                        gender: usr.gender,
                        membershipType: usr.membershipType,
                        membershipExpiration:DateTime.parse(usr.membershipExpiration) ,
                        registrationDate:DateTime.parse(usr.registrationDate) ,
                        age: usr.age,
                        address: usr.address,
                        phone: usr.phone,
                        email: usr.email,
                        balance: usr.balance,
                        image_Path: usr.image_Path == '' ? 'none' : usr.image_Path!,
                      );
                      clients.add(client);
                    }

                  }
                });
              }

        print("online data base =========== $clients");
      } else {
        // Load from Hive
        var clientBox = Hive.box<User>('clients');
        setState(() {
          List<User> users=[];
          users = clientBox.values.toList();
          for (var usr in users){
            print("${usr.name} has an operation of type ${usr.operation}");
            if(usr.operation != -1) {
              Client client = Client(
                id: usr.id,
                name: usr.name,
                gender: usr.gender,
                membershipType: usr.membershipType,
                membershipExpiration:DateTime.parse(usr.membershipExpiration) ,
                registrationDate:DateTime.parse(usr.registrationDate) ,
                age: usr.age,
                address: usr.address,
                phone: usr.phone,
                email: usr.email,
                balance: usr.balance,
                image_Path: usr.image_Path == 'none' ? 'none' : usr.image_Path!,
              );
              clients.add(client);
            }


          }
        });

        print("offline data base =========== $clients");
      }
    }



 @override
  Widget build(BuildContext context) {



      List <Widget> pages = [
       MainPage(clients: clients, plans: abonment,), // Replace with your page widgets
       StatisticsPage(clients: clients),
        PlansPage(
        plans: abonment,
        ),

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
      clients:clients,
      plans: abonment,
    ),
  ),
  );

            },
          ),
        ],
      ),
      body:RefreshIndicator(child: pages.elementAt(_currentIndex) , onRefresh: () async {

        bool connected = await isConnected();

        if(connected)
          {
            var clientBox = Hive.box<User>('clients');

            RefreshwithOnlineBase(clientBox);


          }
        else{
        print(  "no connection to refresh");
        }


      }),
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
            Icon(Icons.card_membership,  color:_currentIndex!=2 ? Colors.white : gren,size: 36,),Text('Plans',style: TextStyle( color:_currentIndex!=2 ? Colors.white : gren))
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
            Icon(Icons.logo_dev_outlined, color:_currentIndex!=3 ? Colors.white : gren,size: 36,),Text('Credit',style: TextStyle( color:_currentIndex!=3 ? Colors.white : gren))
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
             Navigator.push(context , MaterialPageRoute(builder: (context){return MembershipFormPage(plans: abonment,);}));
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

