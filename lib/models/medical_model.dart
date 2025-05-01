import 'package:uuid/uuid.dart';

class MedicalCondition {
  String medicalConditionId;
  String medicalConditionCreatorId;
  String name;
  String description;

  MedicalCondition(
      {required this.medicalConditionId,
      required this.medicalConditionCreatorId,
      required this.name,
      required this.description});

  //Constructor for a new MedicalCondition
  MedicalCondition.newMedicalCondition(
    this.medicalConditionCreatorId,
    this.name,
    this.description,
  ) : medicalConditionId = '';

  //Factory constructor to create a MedicalCondition from a Firestore document snapshot
  factory MedicalCondition.fromMap(String medicalConditionId, Map<String, dynamic> map) {
    return MedicalCondition(
      medicalConditionId: medicalConditionId,
      medicalConditionCreatorId: map['medicalConditionCreatorId'],
      name: map['name'],
      description: map['description'],
    );
  }

  //Generates a random unique Id
  void generateId() {
    medicalConditionId = const Uuid().v4();
  }
}
