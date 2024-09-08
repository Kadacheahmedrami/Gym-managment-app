import 'package:firebase_auth/firebase_auth.dart';
import 'package:hive/hive.dart';

part 'local.g.dart';

@HiveType(typeId: 0)
class User extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String gender;

  @HiveField(3)
  final String membershipType;

  @HiveField(4)
  final String membershipExpiration;

  @HiveField(5)
  final String registrationDate;

  @HiveField(6)
  final int age;

  @HiveField(7)
  final String address;

  @HiveField(8)
  final String phone;

  @HiveField(9)
  final String email;

  @HiveField(10)
  final double balance;

  @HiveField(11)
  final String image_Path;

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
    required this.image_Path,
  });
}
@HiveType(typeId: 1)
class Demand extends HiveObject {
  @HiveField(0)
  final String type; // 'add', 'delete', 'edit'

  @HiveField(1)
  final String userId; // For DeleteDemand and EditDemand

  @HiveField(2)
  final User? user; // For AddDemand

  @HiveField(3)
  final String? editedFeature; // For EditDemand

  @HiveField(4)
  final dynamic newValue; // For EditDemand

  Demand({
    required this.type,
    this.userId = '',
    this.user,
    this.editedFeature,
    this.newValue,
  });
}