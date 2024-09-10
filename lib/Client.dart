import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hamza_gym/animation.dart';

import 'package:hamza_gym/main.dart';
import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

import 'addclient.dart';
import 'local.dart';


Future<void> deleteUserById(String userId) async {
  // Open the Hive box
  var userBox = Hive.box<User>('clients');

  // Find the user by id
  final userToDelete = userBox.values.firstWhere(
        (user) => user.id == userId,
     // Return null if no user is found
  );

  if (userToDelete != null) {
    // Delete the user from the box
    await userToDelete.delete();
    print('User with id $userId deleted.');
  } else {
    print('User with id $userId not found.');
  }
}

Future<void> updateUser(String userId, String? title, dynamic value) async {
  var userBox = Hive.box<User>('clients');

  final userToUpdate = userBox.values.firstWhere(
        (user) => user.id == userId,

  );

  if (userToUpdate != null && title != null) {
    switch (title) {
      case 'name':
        userToUpdate.name = value;
        break;
      case 'gender':
        userToUpdate.gender = value;
        break;
      case 'plan':
        userToUpdate.membershipType = value;
        break;
      case 'exp_date':
        userToUpdate.membershipExpiration = value;
        break;
      case 'address':
        userToUpdate.address = value;
        break;
      case 'number':
        userToUpdate.phone = value;
        break;
      case 'email':
        userToUpdate.email = value;
        break;
      case 'balance':
        userToUpdate.balance = value;
        break;
      case 'operation':
        userToUpdate.operation = value;
        break;
      default:
      // Handle unknown titles if necessary
        break;
    }

    await userToUpdate.save(); // Save the updated user object back to Hive
  } else {
    // Handle the case where the user is not found or title is invalid
    print('User not found or invalid title provided.');
  }
}




class ProfilePage extends StatefulWidget {
  final Client client;

  ProfilePage({required this.client});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _genderController;
  late TextEditingController _membershipTypeController;
  late TextEditingController _expirationDateController;
  late TextEditingController _ageController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _balanceController;

  List plans = [
    {'name': '1 month', 'days': 30, 'price': 1800},
    {'name': '3 months', 'days': 90, 'price': 5000},
    {'name': '6 months', 'days': 180, 'price': 9000},
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.client.name);
    _genderController = TextEditingController(text: widget.client.gender);
    _membershipTypeController = TextEditingController(text: widget.client.membershipType);
    _expirationDateController = TextEditingController(text: DateFormat('yyyy-MM-dd').format(widget.client.membershipExpiration));
    _ageController = TextEditingController(text: widget.client.age.toString());
    _addressController = TextEditingController(text: widget.client.address);
    _phoneController = TextEditingController(text: widget.client.phone);
    _emailController = TextEditingController(text: widget.client.email);
    _balanceController = TextEditingController(text: widget.client.balance.toString());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _genderController.dispose();
    _membershipTypeController.dispose();
    _expirationDateController.dispose();
    _ageController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

 void _showEditDialog(String title, TextEditingController controller, Function(String) onSave) {
  Widget content;

  if (title == 'exp_date') {
    // Date Picker
    content = TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Enter new $title',
        suffixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );

            if (pickedDate != null) {
              String formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);
              controller.text = formattedDate;
            }
          },
        ),
      ),
    );
  } else if (title == 'plan') {
    // Dropdown for Plans
    content = DropdownButtonFormField<String>(
      value: controller.text,
      items: plans.map((plan) {
        return DropdownMenuItem<String>(
          value: plan['name'],
          child: Text('${plan['name']} - \$${plan['price']}'),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.text = newValue;
        }
      },
      decoration: InputDecoration(hintText: 'Select $title'),
    );
  } else if (title == 'gender') {
    // Dropdown for Gender
    content = DropdownButtonFormField<String>(
      value: controller.text,
      items: ['Female', 'Male'].map((gender) {
        return DropdownMenuItem<String>(
          value: gender,
          child: Text(gender),
        );
      }).toList(),
      onChanged: (String? newValue) {
        if (newValue != null) {
          controller.text = newValue;
        }
      },
      decoration: InputDecoration(hintText: 'Select $title'),
    );
  } else {
    // Default Text Field
    content = TextField(
      controller: controller,
      decoration: InputDecoration(hintText: 'Enter new $title'),
    );
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Edit $title'),
        content: content,
        actions: <Widget>[
          TextButton(
            onPressed: () async {
              onSave(controller.text);
              bool connected = await isConnected();


              if(widget.client.id != '' && connected)
                {

                      await FirebaseFirestore.instance
                          .collection('clients')
                          .doc(widget.client.id)
                          .update({title: controller.text});

                }
              else{
                if(widget.client.id == ''){

                }
                else{

                  await updateUser(widget.client.id, 'operation', 2);
                }
              }
              await updateUser(widget.client.id, title, controller.text);

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => Draweranimation(email: 'email', password: '',fix: true,)),
                    (Route<dynamic> route) => false,
              );

            },


            child: const Text('Save'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

  void _showRenewMembershipDialog() {
    int selectedPlanIndex = 0; // Default to the first plan
    double updatedBalance = widget.client.balance + plans[selectedPlanIndex]['price'];
    TextEditingController _paidAmountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Renew Membership'),
          content: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Column(
                    children: List<Widget>.generate(plans.length, (int index) {
                      return RadioListTile<int>(
                        title: Text('${plans[index]['name']} - \$${plans[index]['price']}'),
                        value: index,
                        groupValue: selectedPlanIndex,
                        onChanged: (int? value) {
                          setState(() {
                            selectedPlanIndex = value!;
                            updatedBalance = widget.client.balance + plans[selectedPlanIndex]['price'];
                          });
                        },
                      );
                    }),
                  ),
                  TextField(
                    controller: _paidAmountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Paid Amount'),
                    onChanged: (value) {
                      final paidAmount = double.tryParse(value) ?? 0.0;
                      setState(() {
                        updatedBalance = widget.client.balance + plans[selectedPlanIndex]['price'] - paidAmount;
                      });
                    },
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Updated Balance: \$${updatedBalance.toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async{
                final paidAmount = double.tryParse(_paidAmountController.text) ?? 0.0;

  DateTime expirationDate = widget.client.membershipExpiration.add(Duration(days: plans[selectedPlanIndex]['days']));
  
  // Format the expiration date to "YYYY-MM-DD"
  print(widget.client.membershipExpiration);
   print(expirationDate.toIso8601String().substring(0, 10));
   print(updatedBalance.toString());
   print( plans[selectedPlanIndex]['name']);

                var userBox = Hive.box<User>('clients');

                // Find the user by id
                final userToUpdate = userBox.values.firstWhere(
                      (user) => user.id == widget.client.id,
                  // Return null if no user is found
                );

                userToUpdate.balance = updatedBalance;
                userToUpdate.membershipType = plans[selectedPlanIndex]['name'] ;
                userToUpdate.membershipExpiration =  expirationDate.toIso8601String().substring(0, 10);

                await userToUpdate.save();

                await FirebaseFirestore.instance.collection('clients').doc(widget.client.id).update({'balance':updatedBalance.toString() , 'plan' : plans[selectedPlanIndex]['name'],'exp_date':expirationDate.toIso8601String().substring(0, 10)});
                
                       Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Draweranimation(email: 'email',password: '',fix: true,)),
    (Route<dynamic> route) => false,  // This removes all the previous routes
  );
              },
              child: const Text('Confirm'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void _deleteClient() {
      print(widget.client.id);
    showDialog(
      
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this client?'),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                bool connected = await isConnected();
                if(widget.client.id != '' && connected)
                  {
                    await FirebaseFirestore.instance.collection('clients').doc(widget.client.id).delete();
                    if(widget.client.image_Path != 'none')
                    {
                      Reference storageRef = FirebaseStorage.instance.ref().child('${widget.client.name}.jpg');

                      // Delete the file
                      await storageRef.delete();
                    }
                    deleteUserById(widget.client.id);
                  }
                else{
                  if(widget.client.id ==''){
                    deleteUserById(widget.client.id);
                  }
                  else{
                  await updateUser(widget.client.id, 'operation', -1);
                  }
                }


              Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (context) => Draweranimation(email: 'email',password: '',fix: true,)),
    (Route<dynamic> route) => false,  // This removes all the previous routes
  );
             // Pop the profile page
              },
              child: const Text('Yes'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('No'),
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
        foregroundColor: Colors.white,
        backgroundColor: back,
        title: Text('${widget.client.id}\'s Profile', style: TextStyle(color: gren)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deleteClient,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Profile Image Container
Container(
  height: 150,
  width: 150,
  decoration: BoxDecoration(
    gradient: widget.client.image_Path == 'none'
        ? LinearGradient(
            colors: [Colors.blue, Colors.purple],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null, // No gradient if an image is present
    shape: BoxShape.circle,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.5),
        spreadRadius: 4,
        blurRadius: 10,
        offset: Offset(0, 5),
      ),
    ],
    image: widget.client.image_Path != 'none'
        ? DecorationImage(
            image: NetworkImage(widget.client.image_Path),
            fit: BoxFit.cover,
          )
        : null, // No image if the path is 'none'
  ),
  child: widget.client.image_Path == 'none'
      ? Center(
          child: Icon(
            Icons.person,
            size: 100,
            color: Colors.white,
          ),
        )
      : null, // No icon if an image is present
),

              const SizedBox(height: 30),
              // Renew Membership Button
              ElevatedButton(
                onPressed: _showRenewMembershipDialog,
                style: ElevatedButton.styleFrom(
                  foregroundColor: back, backgroundColor: gren,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Renew Membership',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              // Profile Details
              _buildDetailCard('name', _nameController, (value) {
                // Handle name change
              }),
              _buildDetailCard('gender', _genderController, (value) {
                // Handle gender change
              }),
              _buildDetailCard('plan', _membershipTypeController, (value) {
                // Handle membership type change
              }),
              _buildDetailCard('exp_date', _expirationDateController, (value) {
                // Handle expiration date change
              }),
           
              _buildDetailCard('address', _addressController, (value) {
                // Handle address change
              }),
              _buildDetailCard('number', _phoneController, (value) {
                // Handle phone change
              }),
              _buildDetailCard('email', _emailController, (value) {
                // Handle email change
              }),
              _buildDetailCard('balance', _balanceController, (value) {
                // Handle balance change
              }),
            ],
          ),
        ),
      ),
      backgroundColor: back,
    );
  }

  Widget _buildDetailCard(String title, TextEditingController controller, Function(String) onSave) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      color: shadow,
      elevation: 5,
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        subtitle: TextField(
          controller: controller,
          style: const TextStyle(color: Colors.white70),
          decoration: InputDecoration.collapsed(hintText: ''),
          readOnly: true,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.edit, color: Colors.white),
          onPressed: () => _showEditDialog(title, controller, onSave),
        ),
      ),
    );
  }
}
