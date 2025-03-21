import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Event {
  String eventId;
  String title;
  String eventCreatorId;
  DateTime date;
  String time;

  Event({
    required this.eventId,
    required this.title,
    required this.eventCreatorId,
    required this.date,
    required this.time
  });

  //Constructor for a new MedicalCondition
  Event.newEvent(
      this.eventCreatorId,
      this.title,
      this.date
      )
      : eventId = '',
      time = '';

  void generateId() {
    eventId = Uuid().v4();
  }
}