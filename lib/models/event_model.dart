import 'package:uuid/uuid.dart';

class Event {
  String eventId;
  String title;
  String eventCreatorId;
  DateTime date;
  String time;

  Event(
      {required this.eventId,
      required this.title,
      required this.eventCreatorId,
      required this.date,
      required this.time});

  //Constructor for a new Event
  Event.newEvent(this.eventCreatorId, this.title, this.date)
      : eventId = '',
        time = '';

  //Generates a random unique Id
  void generateId() {
    eventId = const Uuid().v4();
  }
}
