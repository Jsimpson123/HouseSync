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

  Future<void> addCalendarEvent(Event newEvent, String userId) async {
    newEvent.generateId();

    User? user = FirebaseAuth.instance.currentUser;

    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user?.uid).get();
    final groupId = await userDoc.data()?['groupId'];

    await _firestore.collection('calendarEvents').doc(newEvent.eventId).set({
      'eventId': newEvent.eventId,
      'title': newEvent.title,
      'eventCreatorId': userId,
      'groupId': groupId
    });

    // _events.addAll(newEvent);
    notifyListeners();
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