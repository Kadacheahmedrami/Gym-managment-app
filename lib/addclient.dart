import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:hamza_gym/animation.dart';
import 'package:hamza_gym/trainers.dart';
import 'package:hive/hive.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:io';

import 'local.dart';
import 'main.dart';

Future<bool> isConnected() async {
  try {
    final response = await http.get(Uri.parse('https://www.google.com'));
    return response.statusCode == 200; // 200 means OK
  } catch (e) {
    print('Error checking internet connectivity: $e');
    return false; // Error means not connected
  }
}


Future<DocumentReference> addUser(
    String name,
    String number,
    String plan,
    String paidAmount,
    String balance,
    String registrationDate,
    String gender,
    String email,
    String birthDate,
    String address,
    String membershipExpiration,
    String? imageUrl,
    ) async {
  // Add a new document with a generated ID
  DocumentReference docRef = await FirebaseFirestore.instance.collection('clients').add({
    'name': name,
    'number': number,
    'plan': plan,
    'paidAmount': paidAmount,
    'balance': balance,
    'reg_date': registrationDate,
    'gender': gender,
    'email': email,
    'birth_date': birthDate,

    'address': address,
    'exp_date': membershipExpiration,
    'image_path': imageUrl,
  });
  return docRef;
}


class MembershipFormPage extends StatefulWidget {

final List<Plan> plans;
MembershipFormPage({required this.plans,Key? key}) : super(key: key);

  @override
  _MembershipFormPageState createState() => _MembershipFormPageState();
}

class _MembershipFormPageState extends State<MembershipFormPage> {



  late ConnectivityResult _connectivityResult;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;







  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _planController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();
  final TextEditingController _daysLeftController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _registrationDateController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isExpanded = false;
  int _selectedPlanPrice = 0;
  int _selectedPlanDays = 0;
  File? _imageFile;
  

  final List<String> _genders = ['Male', 'Female'];

CollectionReference clients = FirebaseFirestore.instance.collection('clients');




  String calculateExpirationDate(DateTime registrationDate, int daysLeft) {
    // Convert to UTC to avoid daylight saving time issues
    DateTime registrationDateUTC = DateTime.utc(registrationDate.year, registrationDate.month, registrationDate.day);

    // Calculate expiration date by adding days directly in UTC
    DateTime expirationDate = registrationDateUTC.add(Duration(days: daysLeft));

    // Format the expiration date to "YYYY-MM-DD"
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return formatter.format(expirationDate);
  }




  @override
  List<Plan> plans =[Plan(name: "1 month",duration: "30",price : 1800)];
  void initState() {
    plans.addAll(widget.plans);
    super.initState();



  }

  void dispose() {
    _nameController.dispose();
    _numberController.dispose();
    _planController.dispose();
    _amountController.dispose();
    _balanceController.dispose();
    _daysLeftController.dispose();
    _emailController.dispose();
    _dobController.dispose();
    _addressController.dispose();
    _registrationDateController.dispose();
    _genderController.dispose();
    _scrollController.dispose();

    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Read the image file as bytes
      final imageBytes = await File(pickedFile.path).readAsBytes();

      // Decode the image to modify it
      img.Image? originalImage = img.decodeImage(imageBytes);

      if (originalImage != null) {
        // Resize the image to a smaller size, e.g., 300x300
        img.Image resizedImage = img.copyResize(originalImage, width: 300, height: 300);

        // Encode the resized image back to a file
        final resizedImageFile = File(pickedFile.path)
          ..writeAsBytesSync(img.encodeJpg(resizedImage));

        // Get the file size in bytes
        int fileSizeInBytes = resizedImageFile.lengthSync();

        // Convert to KB
        double fileSizeInKB = fileSizeInBytes / 1024;

        // Convert to MB (optional)
        double fileSizeInMB = fileSizeInKB / 1024;

        print('File size: ${fileSizeInBytes} bytes');
        print('File size: ${fileSizeInKB.toStringAsFixed(2)} KB');
        print('File size: ${fileSizeInMB.toStringAsFixed(2)} MB');

        setState(() {
          _imageFile = resizedImageFile;
        });
      }
    }
  }


  bool _validateFields() {
    // Check if the required fields are not empty
    if (_nameController.text.isEmpty) {
      _showErrorDialog('Please enter the name.');
      return false;
    }
    if (_numberController.text.isEmpty) {
      _showErrorDialog('Please enter the number.');
      return false;
    }
    if (_planController.text.isEmpty) {
      _showErrorDialog('Please select a plan.');
      return false;
    }
    if (_amountController.text.isEmpty) {
      _showErrorDialog('Please enter the paid amount.');
      return false;
    }
    if (_registrationDateController.text.isEmpty) {
      _showErrorDialog('Please select a registration date.');
      return false;
    }
    if (_genderController.text.isEmpty) {
      _showErrorDialog('Please select a gender.');
      return false;
    }

    // Validate the format of the fields (e.g., number, email, etc.)
    if (!RegExp(r'^\d{10}$').hasMatch(_numberController.text)) {
      _showErrorDialog('Please enter a valid 10-digit number.');
      return false;
    }
    if (_emailController.text.isNotEmpty &&
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text)) {
      _showErrorDialog('Please enter a valid email address.');
      return false;
    }

    return true;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: shadow,
        title: Text('Error', style: TextStyle(color: Colors.white)),
        content: Text(message, style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: gren)),
          ),
        ],
      ),
    );
  }
  int oneTimeAdd = 1;
void _onConfirm() {

  if (_validateFields() && oneTimeAdd == 1) {
    final String name = _nameController.text;
    final String number = _numberController.text;
    final String plan = _planController.text;
    final String paidAmount = _amountController.text; // Changed to match parameter name in addUser
    final String balance = _balanceController.text;
    final String daysLeft = _daysLeftController.text;
    final String email = _emailController.text;
    final String birthDate = _dobController.text; // Changed to match parameter name in addUser
    final String address = _addressController.text;
    final String registrationDate = _registrationDateController.text; // Changed to match parameter name in addUser
    final String gender = _genderController.text;

    showDialog(
      context: context,
      builder: (context) =>  
      AlertDialog(
        backgroundColor: shadow,
        content: Text(
          'Name: $name\nNumber: $number\nPlan: $plan\nAmount Paid: $paidAmount\nBalance: $balance\nDays Left: $daysLeft\n'
          'Registration Date: $registrationDate\nGender: $gender\nEmail: $email\nDate of Birth: $birthDate\nAddress: $address \n expiration date: ${calculateExpirationDate(DateTime.parse(registrationDate),int.parse(daysLeft) )}' ,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
          onPressed: () async {
            setState(() {
              oneTimeAdd = 0;
            });
    // Show a loading indicator
    showDialog(
    context: context,
    builder: (context) => AlertDialog(
    backgroundColor: shadow,
    content: Container(
    width: 100,
    height: 400,
    child: Center(child: CircularProgressIndicator()),
    ),
    ),
    );

    bool connected = await isConnected();
    var clientBox = Hive.box<User>('clients');

    User newUser = User(
      id: '',
      name: name,
      gender: gender,
      membershipType: plan,
      membershipExpiration: calculateExpirationDate(DateTime.parse(registrationDate), int.parse(daysLeft)),
      registrationDate: registrationDate,
      age: 20,
      address: address,
      phone: number,
      email: email,
      balance: double.parse(balance),
      image_Path: 'none',
      operation: 0
    );


    if (connected) {
      print('there is an internet connection');
      String? imageUrl;

      // Upload image if available
      if (_imageFile != null) {
        var refStorage = FirebaseStorage.instance.ref('${name}.jpg');
        await refStorage.putFile(_imageFile!);
        imageUrl = await refStorage.getDownloadURL();
        print(imageUrl);
      } else {
        imageUrl = 'none';
      }

      // Add the user to Firestore and get the document ID
      DocumentReference docRef = await addUser(
        name,
        number,
        plan,
        paidAmount,
        balance,
        registrationDate,
        gender,
        email,
        birthDate,
        address,
        calculateExpirationDate(DateTime.parse(registrationDate), int.parse(daysLeft)),
        imageUrl,
      );

      // Use the Firestore-generated document ID
      String id = docRef.id;
      newUser.id=id;
      newUser.image_Path = imageUrl;



      // Save the user to the Hive local database


      // Navigate to the next page and remove the loading indicator

    } else {
      newUser.operation=1;
      print('No internet connection');
    }

    await clientBox.add(newUser);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => Draweranimation(email: email, password: '',fix: true,index: 0,)),
          (Route<dynamic> route) => false,
    );

    },



        child:  Text('OK', style: TextStyle(color: gren)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close the dialog without taking action
            },
            child: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


  void _calculateBalance() {
    final amountPaid = int.tryParse(_amountController.text) ?? 0;
    final balance =- _selectedPlanPrice + amountPaid;
    _balanceController.text = balance.toString();
  }

  void _calculateDaysLeft() {
    if (_registrationDateController.text.isNotEmpty) {
      DateTime registrationDate = DateTime.parse(_registrationDateController.text);
      DateTime expirationDate = registrationDate.add(Duration(days: _selectedPlanDays));
      int daysLeft = expirationDate.difference(DateTime.now()).inDays+1;
      _daysLeftController.text = daysLeft.toString();
    }
  }

  Future<void> _selectDate(BuildContext context, TextEditingController controller) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        controller.text = picked.toIso8601String().substring(0, 10); // Formats as YYYY-MM-DD
        if (controller == _registrationDateController) {
          _calculateDaysLeft();
          _calculateDaysLeft();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {


    return Scaffold(
      backgroundColor: back,
      appBar: AppBar(
        backgroundColor: back,
        foregroundColor: Colors.white,
        title: Text('Adding Client', style: TextStyle(color: gren, fontSize: 30)),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(10.0),
          child: SingleChildScrollView(
            controller: _scrollController,
            child: Column(
              children: [
                _buildImagePicker(),
                SizedBox(height: 16.0),
                _buildTextField(_nameController, 'Name'),
                SizedBox(height: 16.0),
                _buildTextField(_numberController, 'Number', TextInputType.number),
                SizedBox(height: 16.0),
                _buildDropdownField(plans),
                SizedBox(height: 16.0),
                _buildTextField(_amountController, 'Paid Amount', TextInputType.number, (value) {
                  _calculateBalance();
                }),
                SizedBox(height: 16.0),
                _buildTextField(_balanceController, 'Balance', TextInputType.number, null, true),
                SizedBox(height: 16.0),
                _buildDatePickerField(_registrationDateController, 'Registration Date', context),
                SizedBox(height: 16.0),
                _buildTextField(_daysLeftController, 'Days Left', TextInputType.number, null, true),
                SizedBox(height: 16.0),
                _buildGenderDropdown(),
                SizedBox(height: 20.0),
                _buildExpandableDetails(),
                SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed:() async{


                  _onConfirm();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: gren,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 140),
                  ),
                  child: Text('Confirm', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold,color: back)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker() {
    return GestureDetector(
        onTap: () async {
      bool connected = await isConnected();
      if (connected) {
        _pickImage();
      } else {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('No internet connection'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }


      } ,
      child: Container(
        width: 150,
        height: 150,
        decoration: BoxDecoration(
          border: Border.all(color: gren ,width: 3),
          color: theme ? shadow : Colors.blueGrey[100],
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Center(
          child: _imageFile == null
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt, color: theme ? Colors.white : gren, size: 50),
                    SizedBox(height: 10),
                    Text('Capture', style: TextStyle(color:theme ? Colors.white : gren, fontWeight: FontWeight.bold, fontSize: 30)),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.file(
                    _imageFile!,
                    fit: BoxFit.cover,
                    height: 150,
                    width: 150,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      [TextInputType keyboardType = TextInputType.text, Function(String)? onChanged, bool readOnly = false]) {
    return Container(
         margin: EdgeInsets.symmetric(vertical: 2),
      height: 56,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: TextStyle(color: back),
        onChanged: onChanged,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: TextStyle(color:theme ? back : Colors.black),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15.0),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
        ),
      ),
    );
  }

  Widget _buildDropdownField(List<Plan> plans) {
    return Container(
         margin: EdgeInsets.symmetric(vertical: 2),
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _planController.text.isNotEmpty ? _planController.text : null,
          hint: Text('Type of Plan', style: TextStyle(color:theme ? back : Colors.black)),
          icon: Icon(Icons.arrow_drop_down, color:theme ? back : Colors.black),
          isExpanded: true,
          items: plans.map<DropdownMenuItem<String>>((plan) {
            return DropdownMenuItem<String>(
              value: plan.name,
              child: Text(plan.name, style: TextStyle(color: back)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _planController.text = newValue!;
              final selectedPlan = plans.firstWhere((plan) => plan.name == newValue);
              _selectedPlanPrice = selectedPlan.price;
              _selectedPlanDays =int.parse(selectedPlan.duration) ;
              _calculateBalance();
              _calculateDaysLeft();
            });
          },
        ),
      ),
    );
  }

  Widget _buildDatePickerField(TextEditingController controller, String labelText, BuildContext context) {
    return GestureDetector(
      onTap: () => _selectDate(context, controller),
      child: AbsorbPointer(
        child: _buildTextField(controller, labelText),
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 20.0),
      margin: EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _genderController.text.isNotEmpty ? _genderController.text : null,
          hint: Text('Gender', style: TextStyle(color: theme ? back : Colors.black )),
          icon: Icon(Icons.arrow_drop_down, color: theme ? back : Colors.black),
          isExpanded: true,
          items: _genders.map<DropdownMenuItem<String>>((gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender, style: TextStyle(color: back)),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _genderController.text = newValue!;
            });
          },
        ),
      ),
    );
  }

  Widget _buildExpandableDetails() {
    return Container(
   
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30.0),
        color: shadow,
      ),
      child: ExpansionTile(
        title: Text('Member Details', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        trailing: Icon(
          _isExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          color: Colors.white,
        ),
        backgroundColor: shadow,
        collapsedIconColor: Colors.white,
        collapsedTextColor: Colors.white,
        textColor: Colors.white,
        iconColor: Colors.white,
        childrenPadding: EdgeInsets.all(10.0),
        onExpansionChanged: (bool expanded) {
          setState(() {
            _isExpanded = expanded;
            if (expanded) {
              Future.delayed(Duration(milliseconds: 200)).then((_) {
                _scrollController.animateTo(
                  400,
                  duration: Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              });
            }
          });
        },
        children: [
          _buildTextField(_emailController, 'Email', TextInputType.emailAddress),
          SizedBox(height: 16.0),
          _buildDatePickerField(_dobController, 'Date of Birth', context),
          SizedBox(height: 16.0),
          _buildTextField(_addressController, 'Address'),
        ],
      ),
    );
  }
}
