import 'package:flutter/material.dart';

import 'package:hive/hive.dart';

import 'animation.dart';
import 'local.dart';
import 'main.dart';

Color textColor = Colors.white;
Color shadowColor = Colors.white10;

class PlansPage extends StatefulWidget {
  List<Plan>? plans;

  PlansPage({this.plans, Key? key}) : super(key: key);

  @override
  _PlansPageState createState() => _PlansPageState();
}

class _PlansPageState extends State<PlansPage> {
  void _addOrEditPlan({Plan? plan, int? index}) {
    final TextEditingController nameController =
    TextEditingController(text: plan?.name ?? '');
    final TextEditingController durationController =
    TextEditingController(text: plan?.duration ?? '');
    final TextEditingController priceController =
    TextEditingController(text: plan?.price.toString() ?? '');

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(plan == null ? 'Add Plan' : 'Edit Plan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Plan Name'),
              ),
              TextField(
                controller: durationController,
                decoration:
                InputDecoration(labelText: 'Duration (e.g., 30 days)'),
              ),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Price (in Da)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.isNotEmpty &&
                    durationController.text.isNotEmpty &&
                    priceController.text.isNotEmpty) {
                  final newMembership = Membership(
                    name: nameController.text,
                    duration: durationController.text,
                    price: int.parse(priceController.text),
                  );

                  var membershipBox = await Hive.openBox<Membership>('membershipBox');

                  if (plan == null) {
                    // Add new membership
                    await membershipBox.add(newMembership);
                  } else {
                    // Update existing membership
                    await membershipBox.putAt(index!, newMembership);
                  }

                  // Optionally update local state or refresh data
                  setState(() {});

                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => Draweranimation(
                          email: 'email',
                          password: '',
                          fix: true,
                          index: 2,
                        )),
                        (Route<dynamic> route) => false,
                  );
                }
              },
              child: Text(plan == null ? 'Add' : 'Save'),
            ),
          ],
        );
      },
    );
  }

  void _deletePlan(int index) async {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Plan'),
          content: Text('Are you sure you want to delete this plan?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                // Open the Hive box
                var membershipBox = await Hive.openBox<Membership>('membershipBox');

                // Delete the plan from the Hive box
                await membershipBox.deleteAt(index);

                // Update the UI
                setState(() {
                  widget.plans!.removeAt(index);
                });

                Navigator.of(context).pop();
              },
              child: Text('Delete'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Plans',style: TextStyle(color: theme ? Colors.black : Colors.white),),

        backgroundColor: gren, // Updated
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: back, // Updated
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Text(
                'Our Plans',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: gren, // Updated
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  _addOrEditPlan();
                },
                icon: Icon(Icons.add, color: back), // Updated
                label: Text(
                  'Add Plan',
                  style: TextStyle(color: back), // Updated
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: gren, // Updated
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              SizedBox(height: 30),
              _buildStaticPlanCard(),
              SizedBox(height: 20),
              Container(
                height: MediaQuery.of(context).size.height * 0.5, // Set height for ListView
                child: ListView.builder(
                  shrinkWrap: true, // Ensures ListView takes only required height
                  itemCount: widget.plans!.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onLongPress: () {
                        _deletePlan(index);
                      },
                      child: _buildPlanCard(widget.plans![index], index),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }

  Widget _buildPlanCard(Plan plan, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: shadow, // Updated
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            blurRadius: 5,
            offset: Offset(-2, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: gren, // Updated
            child: Text(
              plan.name[0],
              style: TextStyle(
                color: back, // Updated
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                plan.name,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                plan.duration,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
              SizedBox(height: 5),
              Text(
                'Price: ${plan.price} Da',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.edit, color: gren), // Updated
            onPressed: () {
              _addOrEditPlan(plan: plan, index: index);
            },
          ),
        ],
      ),
    );
  }
}

class Plan {
  final String name;
  final String duration;
  final int price;

  Plan({
    required this.name,
    required this.duration,
    required this.price,
  });
}

Widget _buildStaticPlanCard() {
  final Plan staticPlan = Plan(
    name: '1 month',
    duration: '30 days',
    price: 1800,
  );

  return Container(
    margin: const EdgeInsets.symmetric(vertical: 10),
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: shadow, // Updated
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          blurRadius: 5,
          offset: Offset(-2, 1),
        ),
      ],
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 25,
          backgroundColor: gren, // Updated
          child: Text(
            staticPlan.name[0],
            style: TextStyle(
              color: back, // Updated
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(width: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              staticPlan.name,
              style: TextStyle(
                fontSize: 18,
                color: textColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              staticPlan.duration,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
            SizedBox(height: 5),
            Text(
              'Price: ${staticPlan.price} Da',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
        Spacer(),
        // Remove the IconButton to make the card unmodifiable
      ],
    ),
  );
}
