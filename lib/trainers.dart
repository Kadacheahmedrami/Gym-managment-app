import 'package:flutter/material.dart';

Color primaryColor = const Color(0xff1c2126);
Color accentColor = const Color(0xffEDFE10);
Color cardColor = const Color(0xff2a3036);
Color textColor = Colors.white;
Color shadowColor = Colors.white10;

class TrainerPage extends StatelessWidget {
  final List<Trainer> trainers;

  TrainerPage({required this.trainers, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Trainers'),
        backgroundColor: accentColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
        color: primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              'Our Trainers',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: accentColor,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Add trainer button logic here
              },
              icon: Icon(Icons.add, color: primaryColor),
              label: Text(
                'Add Trainer',
                style: TextStyle(color: primaryColor),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: accentColor,
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                itemCount: trainers.length,
                itemBuilder: (context, index) {
                  return _buildTrainerCard(trainers[index]);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrainerCard(Trainer trainer) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
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
            backgroundColor: accentColor,
            child: Text(
              trainer.name[0],
              style: TextStyle(
                color: primaryColor,
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
                trainer.name,
                style: TextStyle(
                  fontSize: 18,
                  color: textColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 5),
              Text(
                trainer.specialty,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
          Spacer(),
          IconButton(
            icon: Icon(Icons.edit, color: accentColor),
            onPressed: () {
              // Edit trainer logic here
            },
          ),
        ],
      ),
    );
  }
}

class Trainer {
  final String name;
  final String specialty;

  Trainer({
    required this.name,
    required this.specialty,
  });
}
