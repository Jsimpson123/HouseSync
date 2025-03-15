import 'package:uuid/uuid.dart';

class Event {
  String eventId;
  String title;
  String eventCreatorId;
  DateTime date;

  Event({
    required this.eventId,
    required this.title,
    required this.eventCreatorId,
    required this.date
  });

  //Constructor for a new MedicalCondition
  Event.newEvent(
      this.eventCreatorId,
      this.title,
      this.date
      )
      : eventId = '';

  void generateId() {
    eventId = Uuid().v4();
  }
}