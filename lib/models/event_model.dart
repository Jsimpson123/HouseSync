import 'package:uuid/uuid.dart';

class Event {
  String eventId;
  String title;
  String eventCreatorId;

  Event({
    required this.eventId,
    required this.title,
    required this.eventCreatorId});

  //Constructor for a new MedicalCondition
  Event.newEvent(
      this.eventCreatorId,
      this.title,
      )
      : eventId = '';

  void generateId() {
    eventId = Uuid().v4();
  }
}