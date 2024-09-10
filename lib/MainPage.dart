import 'package:flutter/material.dart';
import 'package:hamza_gym/ClientCard.dart';
import 'package:hamza_gym/main.dart';
import 'package:hamza_gym/trainers.dart'; // Ensure ClientCard is correctly implemented

Color gren = const Color(0xffEDFE10);
Color back = const Color(0xff1c2126);
Color shadow = const Color(0xff2a3036);

int daysLeftUntil(String targetDate) {
  DateTime target = DateTime.parse(targetDate);
  DateTime now = DateTime.now();
  return target.difference(now).inDays;
}

class MainPage extends StatefulWidget {
  final List<Client> clients;
  final List<Plan> plans;

  MainPage({required this.clients,required this.plans, Key? key});

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedGender = "All";
  String selectedMembershipType = "All";
  String selectedSortOption = "None";
  String selectedBalanceFilter = "All";

  List<Client>? filteredClients;
  List<String> arr = ['All'];

  List<Plan> plans =[Plan(name: "1 month",duration: "30",price : 1800)];

  @override
  void initState()

  {
    super.initState();
    // Populate arr with plan names
    // Ensure "All" is added only once and the list has unique it_iniems
    arr = ['All'];
    plans.addAll(widget.plans);
    // Populate arr with plan names, avoiding duplicates
    for (Plan p in plans) {
      if (!arr.contains(p.name)) {
        setState(() {
          arr.add(p.name);
        });
      }
    }

    filteredClients = widget.clients;
    _searchController.addListener(_filterClients);
  }

  void _filterClients() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredClients = widget.clients.where((client) {
        final matchesGender = selectedGender == "All" || client.gender == selectedGender;
        final matchesMembership = selectedMembershipType == "All" || client.membershipType == selectedMembershipType;
        final matchesSearch = client.name.toLowerCase().startsWith(query);

        // Balance filter logic
        bool matchesBalance;
        switch (selectedBalanceFilter) {
          case "Negative":
            matchesBalance = client.balance < 0;
            break;
          case "Positive":
            matchesBalance = client.balance > 0;
            break;
          case "Zero":
            matchesBalance = client.balance == 0;
            break;
          default:
            matchesBalance = true;
        }

        return matchesGender && matchesMembership && matchesSearch && matchesBalance;
      }).cast<Client>().toList();

      // Sorting logic
      if (selectedSortOption == "Age") {
        filteredClients!.sort((a, b) => a.age.compareTo(b.age));
      } else if (selectedSortOption == "Closest to Expiration") {
        filteredClients!.sort((a, b) => a.membershipExpiration.compareTo(b.membershipExpiration));
      } else if (selectedSortOption == "Farthest from Expiration") {
        filteredClients!.sort((a, b) => b.membershipExpiration.compareTo(a.membershipExpiration));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Gender Filter
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(top: 20),
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          value: selectedGender,
                          items: ["All", "Male", "Female"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedGender = newValue!;
                              _filterClients();
                            });
                          },
                        ),
                      ),
                      // Membership Filter
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(top: 20, right: 20, left: 20),
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          value: selectedMembershipType,
                          items: arr.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedMembershipType = newValue!;
                              _filterClients();
                            });
                          },
                        ),
                      ),
                      // Sort Option Filter
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(top: 20),
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          value: selectedSortOption,
                          items: ["None", "Age", "Closest to Expiration", "Farthest from Expiration"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedSortOption = newValue!;
                              _filterClients();
                            });
                          },
                        ),
                      ),
                      // Balance Filter
                      Container(
                        padding: const EdgeInsets.only(left: 10),
                        margin: const EdgeInsets.only(top: 20, left: 20),
                        height: 40,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        child: DropdownButton<String>(
                          value: selectedBalanceFilter,
                          items: ["All", "Negative", "Positive", "Zero"].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              selectedBalanceFilter = newValue!;
                              _filterClients();
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: filteredClients!.length,
              itemBuilder: (context, index) {
                return ClientCard(filteredClients![index],plans);
              },
            ),
          ),
        ],
      ),
      backgroundColor: back,
    );
  }
}
