import 'package:hive/hive.dart';

part 'local.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String gender;

  @HiveField(3)
  String membershipType;

  @HiveField(4)
  String membershipExpiration;

  @HiveField(5)
  String registrationDate;

  @HiveField(6)
  int age;

  @HiveField(7)
  String address;

  @HiveField(8)
  String phone;

  @HiveField(9)
  String email;

  @HiveField(10)
  double balance;

  @HiveField(11)
  String? image_Path;

  @HiveField(12)
  int operation;


  User({
    required this.id,
    required this.name,
    required this.gender,
    required this.membershipType,
    required this.membershipExpiration,
    required this.registrationDate,
    required this.age,
    required this.address,
    required this.phone,
    required this.email,
    required this.balance,
    required this.operation,
    this.image_Path,

  });
}

@HiveType(typeId: 1) // Updated for the Membership class
class Membership extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String duration;

  @HiveField(2)
  final int price;

  Membership({
    required this.name,
    required this.duration,
    required this.price,
  });
}