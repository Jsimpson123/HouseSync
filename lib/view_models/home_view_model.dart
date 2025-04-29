import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/event_model.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  //Stores the created calendar events
  final Map<DateTime, List<Event>> _events = {};
  Map <DateTime, List<Event>> get events => Map.unmodifiable(_events);

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;

  Future<void> addCalendarEvent(Event newEvent, String userId, TimeOfDay selectedTime) async {
    newEvent.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    DateTime dateTime = DateTime(
      newEvent.date.year,
      newEvent.date.month,
      newEvent.date.day,
      selectedTime.hour,
      selectedTime.minute
    );

    TimeOfDay time = TimeOfDay(hour: selectedTime.hour, minute: selectedTime.minute);

    await _firestore.collection('calendarEvents').doc(newEvent.eventId).set({
      'eventId': newEvent.eventId,
      'title': newEvent.title,
      'date': Timestamp.fromDate(dateTime),
      'time': time.toString().replaceAll("TimeOfDay(", "").replaceAll(")", ""),
      'eventCreatorId': userId,
      'groupId': groupId
    });

    notifyListeners();
  }

  Future<List<Event>> getEventsForDay(DateTime day) async {
    User? user = FirebaseAuth.instance.currentUser;
    
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];
    
    DateTime dayStart = DateTime(day.year, day.month, day.day, 0, 0, 0);
    DateTime dayEnd = DateTime(day.year, day.month, day.day, 23, 59, 59);
    
    final dateSnapshot = await _firestore.collection('calendarEvents')
        .where('groupId', isEqualTo: groupId)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('date', isLessThanOrEqualTo: Timestamp.fromDate(dayEnd))
        .get();
    
    List<Event> events = dateSnapshot.docs.map((doc) {
      final data = doc.data();

      return Event(
          eventId: data['eventId'],
          title: data['title'],
          eventCreatorId: data['eventCreatorId'],
          date: data['date'] is Timestamp
              ? (data['date'] as Timestamp).toDate() //If its a timestamp, convert to date
              : (data['date'] as DateTime), //if its a DateTime, use it
          time: (data['time'])
      );

    }).toList();

    return events;
  }

  Future<void> updateEvent(String eventId, String newTitle, DateTime newTime) async {
    await FirebaseFirestore.instance
        .collection('calendarEvents')
        .doc(eventId)
        .update({
      'title': newTitle,
      'time': '${newTime.hour}:${newTime.minute.toString()}',
    });
  }

  Future<void> deleteEvent(String eventId) async {
    await FirebaseFirestore.instance.collection('calendarEvents').doc(eventId).delete();

    notifyListeners();
  }

  Future<String?> returnEventCreatorUsername (String eventId) async {
    try {
      final eventDoc = FirebaseFirestore.instance.collection('calendarEvents').doc(eventId);
      final docSnapshot = await eventDoc.get();
      final data = docSnapshot.data();

      if (data != null) {
        String creatorId = data['eventCreatorId'];

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(creatorId)
            .get();

        final userName = await userDoc.data()?['username'];

        return userName;
      }
    } catch (e) {
      print("Error retrieving event creator username: $e");
    }
    return null;
  }

  void displayBottomSheet(Widget bottomSheetView, BuildContext context) {
    showModalBottomSheet(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
        clipBehavior: Clip.antiAliasWithSaveLayer,
        context: context,
        isScrollControlled: true,
        builder: ((context) {
          return bottomSheetView;
        }));
  }
}