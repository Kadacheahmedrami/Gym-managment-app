import 'local.dart';


abstract class Demand {
  // This can be an abstract method or property if you need
  // specific behavior for all demands
}

class AddDemand extends Demand {
  final User user;

  AddDemand({
    required this.user,
  });
}

class DeleteDemand extends Demand {
  final String userId;

  DeleteDemand({
    required this.userId,
  });
}

class EditDemand extends Demand {
  final String userId;
  final String editedFeature;
  final dynamic newValue;

  EditDemand({
    required this.userId,
    required this.editedFeature,
    required this.newValue,
  });
}
