import 'package:flutter/material.dart';
import 'package:hamza_gym/Client.dart';
import 'package:hamza_gym/addclient.dart';
import 'package:hamza_gym/main.dart';
import 'package:hamza_gym/trainers.dart';
import 'package:intl/intl.dart'; // For date formatting


Color gren = const Color(0xffEDFE10);
Color back = const Color(0xff1c2126);
Color shadow = const Color(0xff2a3036);



class ClientCard extends StatefulWidget {
  final Client client;
  final List<Plan> plans;
  const ClientCard(this.client,this.plans, {super.key});

  @override
  _ClientCardState createState() => _ClientCardState();
}

class _ClientCardState extends State<ClientCard> {
  int daysLeftUntil(DateTime expirationDate) {
    final today = DateTime.now();
    return expirationDate.difference(today).inDays;
  }



  @override
  Widget build(BuildContext context) {

    Color expir = daysLeftUntil(widget.client.membershipExpiration) <= 0 ? Colors.red : daysLeftUntil(widget.client.membershipExpiration) <= 3 ? Colors.orange : Colors.white;

    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.all(10),
      color: shadow,
      child: GestureDetector(
        onLongPress: (){
          print(widget.client.image_Path);
        },
        onDoubleTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProfilePage(client: widget.client,plans: widget.plans,),
            ),
          );
        },
        child: ExpansionTile(
          collapsedIconColor: Colors.white,
          leading:CircleAvatar(
  radius: 30,
  // Optional: To remove any background color
  backgroundImage: widget.client.image_Path != 'none'
      ? NetworkImage(widget.client.image_Path)
      : null,
  child: widget.client.image_Path == 'none'
      ? Text(
          widget.client.name.substring(0, 1),
          style: const TextStyle(color: Colors.black, fontSize: 30),
        )
      : null, // No child if the image is present
),
          title: Text(widget.client.name, style: TextStyle(  color:expir , fontSize: 20)),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Membership: ${widget.client.membershipType}', style: TextStyle(color: expir, fontSize: 15)),
              Text(daysLeftUntil(widget.client.membershipExpiration)+1 > 0 ? '${daysLeftUntil(widget.client.membershipExpiration)+1} Days left': 'expired' , style: TextStyle(color: expir, fontSize: 15)),
            ],
          ),
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 95,right: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Age: ${widget.client.age}', style: TextStyle(color: expir, fontSize: 15)),
                      Text('Expires: ${DateFormat('MM/dd/yyyy').format(widget.client.membershipExpiration)}', style: TextStyle(color: expir, fontSize: 15)),
                    ],
                  ),
                  const SizedBox(height: 10),
                     Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Gender: ${widget.client.gender}', style: TextStyle(color: expir, fontSize: 15)),
                      Text('Balance:  ${widget.client.balance} Da  ', style: TextStyle(color: expir, fontSize: 15)),
                    ],
                  ),
                 
                  const SizedBox(height: 10),
             
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}