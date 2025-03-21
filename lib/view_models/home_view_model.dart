import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_accommodation_management_app/models/event_model.dart';

class HomeViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // final List<Event> _events = <Event>[];
  // List<Event> get events => List.unmodifiable(_events);

  //Stores the created calendar events
  final Map<DateTime, List<Event>> _events = {};
  Map <DateTime, List<Event>> get events => Map.unmodifiable(_events);

  Color colour1 = Colors.grey.shade50;
  Color colour2 = Colors.grey.shade200;
  Color colour3 = Colors.grey.shade800;
  Color colour4 = Colors.grey.shade900;
  //
  // Future <String?> returnCurrentUsername () async {
  //   final user = FirebaseAuth.instance.currentUser;
  //
  //   if (user != null) {
  //     try {
  //       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  //       final docSnapshot = await userDoc.get();
  //       final data = docSnapshot.data();
  //
  //       if (data != null) {
  //         return data['username'] as String?;
  //       }
  //     } catch (e) {
  //       print("Error retrieving username: $e");
  //     }
  //   }
  //   return null;
  // }
  //
  // Future <String?> returnCurrentEmail () async {
  //   final user = FirebaseAuth.instance.currentUser;
  //
  //   if (user != null) {
  //     try {
  //       final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);
  //       final docSnapshot = await userDoc.get();
  //       final data = docSnapshot.data();
  //
  //       if (data != null) {
  //         return data['email'] as String?;
  //       }
  //     } catch (e) {
  //       print("Error retrieving username: $e");
  //     }
  //   }
  //   return null;
  // }

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
          date: (data['date'] as Timestamp).toDate(),
          time: (data['time'])
      );

    }).toList();

    return events;
  }

  // Future<num?> returnAssignedExpenseAmount (String expenseId) async {
  //   try {
  //     final taskDoc = FirebaseFirestore.instance.collection('expenses').doc(expenseId);
  //     final docSnapshot = await taskDoc.get();
  //     final data = docSnapshot.data();
  //
  //     if (data != null) {
  //       num expenseAmount = data['expenseAmount'];
  //
  //       return expenseAmount;
  //     }
  //   } catch (e) {
  //     print("Error retrieving Amount: $e");
  //   }
  //   return null;
  // }

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