// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'local.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return User(
      id: fields[0] as String,
      name: fields[1] as String,
      gender: fields[2] as String,
      membershipType: fields[3] as String,
      membershipExpiration: fields[4] as String,
      registrationDate: fields[5] as String,
      age: fields[6] as int,
      address: fields[7] as String,
      phone: fields[8] as String,
      email: fields[9] as String,
      balance: fields[10] as double,
      image_Path: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, User obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.gender)
      ..writeByte(3)
      ..write(obj.membershipType)
      ..writeByte(4)
      ..write(obj.membershipExpiration)
      ..writeByte(5)
      ..write(obj.registrationDate)
      ..writeByte(6)
      ..write(obj.age)
      ..writeByte(7)
      ..write(obj.address)
      ..writeByte(8)
      ..write(obj.phone)
      ..writeByte(9)
      ..write(obj.email)
      ..writeByte(10)
      ..write(obj.balance)
      ..writeByte(11)
      ..write(obj.image_Path);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DemandAdapter extends TypeAdapter<Demand> {
  @override
  final int typeId = 1;

  @override
  Demand read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Demand(
      type: fields[0] as String,
      userId: fields[1] as String,
      user: fields[2] as User?,
      editedFeature: fields[3] as String?,
      newValue: fields[4] as dynamic,
    );
  }

  @override
  void write(BinaryWriter writer, Demand obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.userId)
      ..writeByte(2)
      ..write(obj.user)
      ..writeByte(3)
      ..write(obj.editedFeature)
      ..writeByte(4)
      ..write(obj.newValue);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DemandAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
