import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
import 'package:shared_accommodation_management_app/global/common/AppColours.dart';
import 'package:shared_accommodation_management_app/global/common/toast.dart';
import 'package:shared_accommodation_management_app/pages/chores_page.dart';
import 'package:shared_accommodation_management_app/pages/finance_page.dart';
import 'package:shared_accommodation_management_app/pages/login_page.dart';
import 'package:shared_accommodation_management_app/pages/shopping_page.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/bottom_sheets/group_details_bottom_sheet_view.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/calendar_view.dart';
import 'package:shared_accommodation_management_app/views/home_page_views/group_functions_view.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:shared_accommodation_management_app/view_models/home_view_model.dart';

import '../main.dart';
import '../models/event_model.dart';
import '../view_models/group_view_model.dart';
import '../view_models/user_view_model.dart';
import '../views/home_page_views/home_header_view.dart';
import '../views/home_page_views/settings_view.dart';
import 'create_or_join_group_page.dart';
import 'medical_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  User? user = FirebaseAuth.instance.currentUser;

  int index = 0;
  List<Widget> pages = [
    HomePage(),
    ChoresPage(),
    FinancePage(),
    ShoppingPage(),
    MedicalPage(),
  ];

  late final ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  HomeViewModel homeViewModel = HomeViewModel();

  //Map to store the created calendar events
  Map<DateTime, List<Event>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));
    _loadEventsForDay(_selectedDay!);

    Provider.of<GroupViewModel>(context, listen: false).returnAllGroupMembersAsList(user!.uid);
    Provider.of<GroupViewModel>(context, listen: false).memberIds;
    Provider.of<GroupViewModel>(context, listen: false).members;
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }

  Future<void> _loadEventsForDay(DateTime day) async {
    List<Event> calendarEvents = await homeViewModel.getEventsForDay(day);
    _selectedEvents.value = calendarEvents;
  }

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    UserViewModel userViewModel = UserViewModel();

    final TextEditingController enteredEventNameController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: AppColours.colour2(brightness)),

              //User icon
              currentAccountPicture: const Expanded(
                  child: FittedBox(
                fit: BoxFit.fitHeight,
                child: Icon(Icons.account_circle_rounded),
              )),

              //Username
              accountName: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentUsername(),
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(""); //Due to a delay in the username loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text(
                            "${snapshot.data}",
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColours.colour4(brightness)),
                          ),
                        ),
                      );
                    }
                  }),

              //Email
              accountEmail: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentEmail(),
                  builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(""); //Due to a delay in the email loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColours.colour4(brightness))),
                        ),
                      );
                    }
                  }),
            ),
            ListTile(
              title: Text("Group"),
              onTap: () => groupDetails(context),
            ),
            ListTile(
              title: Text("Settings"),
              onTap: () => SettingsView.settingsPopup(context, SettingsView()),
            ),
            ListTile(
                title: Text("Logout"),
                onTap: () async {
                  await FirebaseAuth.instance.signOut().then((value) => Navigator.of(context)
                      .pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => LoginPage()), (route) => false));

                  //Resets the apps theme to light mode
                  MyApp.notifier.value = ThemeMode.light;
                }),
            SizedBox(
              height: 30,
            ),
            Divider(),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
              Icon(Icons.feedback),
              Icon(Icons.bug_report),
            ],),
            Center(
              child: Text(
                "Want to send feedback or report a bug?",
                style: TextStyle(
                    color: AppColours.colour4(brightness),
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Center(
              child: Text(
                "Email: HouseSync@gmail.com",
                style: TextStyle(
                    color: AppColours.colour4(brightness),
                    fontSize: 14),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Divider(),
            Center(
              child: Container(
                width: 190,
                height: 140,
                child: Image.asset('assets/images/housesync_logo.png'),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              Expanded(flex: 2, child: HomeHeaderView()),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.black),
                  ),
                ),
              ),
              Expanded(
                  flex: 5,
                  child: SingleChildScrollView(
                    child: TableCalendar(
                        rowHeight: 35,
                        daysOfWeekHeight: 28,
                        focusedDay: _focusedDay,
                        firstDay: DateTime.utc(2010, 10, 16),
                        lastDay: DateTime.utc(2030, 3, 14),
                        calendarFormat: _calendarFormat,
                        eventLoader: _getEventsForDay,
                        selectedDayPredicate: (day) {
                          return isSameDay(_selectedDay, day);
                        },
                        onDaySelected: (selectedDay, focusedDay) {
                          if (!isSameDay(_selectedDay, selectedDay)) {
                            setState(() {
                              _selectedDay = selectedDay;
                              _focusedDay = focusedDay;
                              //_selectedEvents.value = _getEventsForDay(selectedDay);
                            });
                            _loadEventsForDay(selectedDay);
                          }
                        },
                        onFormatChanged: (format) {
                          if (_calendarFormat != format) {
                            setState(() {
                              _calendarFormat = format;
                            });
                          }
                        },
                        onPageChanged: (focusedDay) {
                          _focusedDay = focusedDay;
                        }),
                  )),
              SizedBox(height: 8.0),
              Expanded(
                flex: 3,
                child: ValueListenableBuilder<List<Event>>(
                    valueListenable: _selectedEvents,
                    builder: (context, value, _) {
                      return Container(
                        decoration: BoxDecoration(
                            color: AppColours.colour2(brightness),
                            borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                        child: Column(
                          children: [
                            Text("Events",
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: AppColours.colour4(brightness))),
                            Expanded(
                              child: SizedBox(
                                height: 200,
                                child: ListView.separated(
                                    padding: EdgeInsets.all(15),
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 15);
                                    },
                                    itemCount: value.length,
                                    itemBuilder: (context, index) {
                                      final TextEditingController enteredEventNameController =
                                          TextEditingController();
                                      final eventCreatorId = value[index].eventCreatorId;
                                      if (user?.uid == eventCreatorId) {
                                        return Dismissible(
                                          //Makes events dismissible via swiping
                                          key: UniqueKey(),
                                          onDismissed: (direction) {
                                            final eventToDelete = value[index];
                                            homeViewModel.deleteEvent(eventToDelete.eventId);

                                            setState(() {
                                              value.removeAt(index);
                                            });
                                          },
                                          background: Container(
                                            margin: EdgeInsets.symmetric(horizontal: 5),
                                            decoration: BoxDecoration(
                                                color: Colors.red,
                                                borderRadius: BorderRadius.circular(10)),
                                            child: Center(child: Icon(Icons.delete)),
                                          ),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: Colors.blueAccent, spreadRadius: 2)
                                                  ],
                                                  color: AppColours.colour1(brightness),
                                                  borderRadius: BorderRadius.circular(20)),
                                              child: ListTile(
                                                onTap: () async {
                                                  //Sets the text to the current event title
                                                  enteredEventNameController.text =
                                                      value[index].title;

                                                  //Splits the time in two parts, before and after the colon
                                                  List<String> parts = value[index].time.split(":");

                                                  //Sets the selected time to the previously selected hour and minute
                                                  TimeOfDay selectedTime = TimeOfDay(
                                                    hour: int.parse(parts[0]),
                                                    minute: int.parse(parts[1]),
                                                  );

                                                  //Holds the value of the original date and time
                                                  DateTime originalDateTime = value[index].date;

                                                  //Boolean for checking if the user changes the time of tge event
                                                  bool isTimeChanged = false;

                                                  homeViewModel.displayBottomSheet(
                                                      Padding(
                                                          padding: EdgeInsets.only(
                                                              bottom: MediaQuery.of(context)
                                                                  .viewInsets
                                                                  .bottom),
                                                          //Ensures the keyboard doesn't cover the textfields
                                                          child: Container(
                                                              height: 250,
                                                              padding: const EdgeInsets.all(16.0),
                                                              child: Column(
                                                                mainAxisSize: MainAxisSize.min,
                                                                children: [
                                                                  Text("Update Event Details",
                                                                      style: TextStyle(
                                                                          fontSize: 20,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                          color: AppColours.colour3(
                                                                              brightness))),
                                                                  SizedBox(height: 15),
                                                                  TextField(
                                                                    key: Key(
                                                                        "updatedEventNameTextField"),
                                                                    decoration: const InputDecoration(
                                                                        hintText: "New Event Name",
                                                                        border:
                                                                            OutlineInputBorder()),
                                                                    controller:
                                                                        enteredEventNameController,
                                                                  ),
                                                                  SizedBox(height: 15),
                                                                  IconButton(
                                                                      onPressed: () async {
                                                                        //Shows the time picker, setting it to the previously set time
                                                                        TimeOfDay?
                                                                            selectedTimePicker =
                                                                            await showTimePicker(
                                                                                context: context,
                                                                                initialTime:
                                                                                    selectedTime);

                                                                        //If the user chooses a new time, the selected time changes, and the boolean becomes true
                                                                        if (selectedTimePicker !=
                                                                            null) {
                                                                          selectedTime =
                                                                              selectedTimePicker;
                                                                          isTimeChanged = true;
                                                                        }
                                                                      },
                                                                      icon: Icon(
                                                                        Icons.more_time,
                                                                      )),
                                                                  SizedBox(height: 15),
                                                                  ElevatedButton(
                                                                      key: Key(
                                                                          "submitNewEventDetailsButton"),
                                                                      child: Text("Submit"),
                                                                      style: ElevatedButton.styleFrom(
                                                                          foregroundColor:
                                                                              AppColours.colour1(
                                                                                  brightness),
                                                                          backgroundColor:
                                                                              AppColours.colour3(
                                                                                  brightness),
                                                                          fixedSize: Size(100, 50)),
                                                                      onPressed: () async {
                                                                        DateTime updatedTime;

                                                                        //Only runs if the user selects a new time
                                                                        if (isTimeChanged) {
                                                                          //Creates a new DateTime with changed time
                                                                          updatedTime = DateTime(
                                                                            originalDateTime.year,
                                                                            originalDateTime.month,
                                                                            originalDateTime.day,
                                                                            selectedTime.hour,
                                                                            selectedTime.minute,
                                                                          );
                                                                        } else {
                                                                          //Keeps the original DateTime
                                                                          updatedTime =
                                                                              originalDateTime;
                                                                        }

                                                                        //Sends the updated details to the database
                                                                        await HomeViewModel()
                                                                            .updateEvent(
                                                                          value[index].eventId,
                                                                          enteredEventNameController
                                                                              .text,
                                                                          updatedTime,
                                                                        );

                                                                        //Updates on screen
                                                                        setState(() {
                                                                          value[index].title =
                                                                              enteredEventNameController
                                                                                  .text;
                                                                          value[index].time =
                                                                              '${selectedTime.hour}:${selectedTime.minute.toString()}';
                                                                        });
                                                                        Navigator.of(context)
                                                                            .pop(); //Makes bottom event bar disappear

                                                                        showToast(
                                                                            message:
                                                                                "New Event: ${enteredEventNameController.text}");
                                                                        showToast(
                                                                            message:
                                                                                "New Time: ${selectedTime.hour}:${selectedTime.minute.toString()}");
                                                                      })
                                                                ],
                                                              ))),
                                                      context);
                                                },
                                                title: Text(value[index].title,
                                                    style: TextStyle(
                                                        fontSize: 20,
                                                        fontWeight: FontWeight.bold,
                                                        color: AppColours.colour4(brightness))),
                                                subtitle: Row(
                                                  children: [
                                                    Icon(Icons.access_time_outlined),
                                                    Text(value[index].time.toString(),
                                                        style: TextStyle(
                                                            fontSize: 16,
                                                            color: AppColours.colour4(brightness))),
                                                  ],
                                                ),
                                                trailing: FutureBuilder<String?>(
                                                    future:
                                                        homeViewModel.returnEventCreatorUsername(
                                                            value[index].eventId),
                                                    builder: (BuildContext context,
                                                        AsyncSnapshot<String?> snapshot) {
                                                      if ("${snapshot.data}" == "null") {
                                                        return const Text(
                                                            ""); //Due to a delay in the username loading
                                                      } else {
                                                        return FittedBox(
                                                          fit: BoxFit.fitHeight,
                                                          child: Column(
                                                            children: [
                                                              Icon(Icons.supervisor_account_sharp,
                                                                  size: 35),
                                                              Text("${snapshot.data}",
                                                                  style: TextStyle(
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.bold,
                                                                      color: AppColours.colour4(
                                                                          brightness))),
                                                            ],
                                                          ),
                                                        );
                                                      }
                                                    }),
                                              )),
                                        );
                                      } else {
                                        return Container(
                                            decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.blueAccent, spreadRadius: 2)
                                                ],
                                                color: AppColours.colour1(brightness),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: ListTile(
                                              title: Text(value[index].title,
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight: FontWeight.bold,
                                                      color: AppColours.colour4(brightness))),
                                              subtitle: Row(
                                                children: [
                                                  Icon(Icons.access_time_outlined),
                                                  Text(value[index].time.toString(),
                                                      style: TextStyle(
                                                          fontSize: 16,
                                                          color: AppColours.colour4(brightness))),
                                                ],
                                              ),
                                              trailing: FutureBuilder<String?>(
                                                  future: homeViewModel.returnEventCreatorUsername(
                                                      value[index].eventId),
                                                  builder: (BuildContext context,
                                                      AsyncSnapshot<String?> snapshot) {
                                                    if ("${snapshot.data}" == "null") {
                                                      return const Text(
                                                          ""); //Due to a delay in the username loading
                                                    } else {
                                                      return FittedBox(
                                                        fit: BoxFit.fitHeight,
                                                        child: Column(
                                                          children: [
                                                            Icon(Icons.supervisor_account_sharp,
                                                                size: 35),
                                                            Text("${snapshot.data}",
                                                                style: TextStyle(
                                                                    fontSize: 18,
                                                                    fontWeight: FontWeight.bold,
                                                                    color: AppColours.colour4(
                                                                        brightness))),
                                                          ],
                                                        ),
                                                      );
                                                    }
                                                  }),
                                            ));
                                      }
                                    }),
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
              )
            ],
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Consumer<HomeViewModel>(builder: (context, viewModel, child) {
        return SizedBox(
          height: 60,
          child: ElevatedButton(
              key: Key("createEventButton"),
              style: ElevatedButton.styleFrom(
                  backgroundColor: AppColours.colour3(brightness),
                  foregroundColor: AppColours.colour1(brightness)),
              onPressed: () => {
                    if (_selectedDay != null)
                      {
                        viewModel.displayBottomSheet(
                            Consumer<HomeViewModel>(builder: (context, viewModel, child) {
                          return Padding(
                              padding:
                                  EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                              //Ensures the keyboard doesn't cover the textfields
                              child: Container(
                                  height: 150,
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextField(
                                          key: Key("eventTextField"),
                                          decoration: const InputDecoration(
                                              hintText: "Event Name", border: OutlineInputBorder()),
                                          controller: enteredEventNameController,
                                          onSubmitted: (value) async {}),
                                      SizedBox(height: 15),
                                      ElevatedButton(
                                          key: Key("submitEventButton"),
                                          child: Text("Submit"),
                                          style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColours.colour3(brightness),
                                              foregroundColor: AppColours.colour1(brightness),
                                              fixedSize: Size(100, 50)),
                                          onPressed: () async {
                                            if (enteredEventNameController.text.isNotEmpty) {
                                              Event newEvent = Event.newEvent(user!.uid,
                                                  enteredEventNameController.text, _focusedDay);

                                              TimeOfDay? selectedTime = await showTimePicker(
                                                  context: context, initialTime: TimeOfDay.now());

                                              viewModel.addCalendarEvent(
                                                  newEvent, user.uid, selectedTime!);
                                              // events.addAll({_selectedDay! : [newEvent]});
                                              setState(() {
                                                if (events.containsKey(_selectedDay)) {
                                                  events[_selectedDay]!
                                                      .add(newEvent); //Adds the new event
                                                } else {
                                                  events[_selectedDay!] = [
                                                    newEvent
                                                  ]; //Creates new list with event
                                                }
                                              });
                                              enteredEventNameController.clear();
                                            }
                                            Navigator.of(context)
                                                .pop(); //Makes bottom event bar disappear
                                            // _selectedEvents.value = _getEventsForDay(_selectedDay!);
                                            _loadEventsForDay(_selectedDay!);
                                          }),
                                    ],
                                  )));
                        }), context)
                      }
                    else
                      {showToast(message: "Please Select A Day")}
                  },
              child: Icon(Icons.add)),
        );
      }),
      bottomNavigationBar: setBottomNavigationBar(),
    );
  }

  PopScope setBottomNavigationBar() {
    return PopScope(
        canPop: false,
        //Ensures that the built-in back button doesn't return to the wrong page
        child: BottomNavigationBar(
          currentIndex: index,
          onTap: (newIndex) {
            // when an item is clicked
            setState(() {
              index = newIndex; // update the index
            });
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => pages[index],
                ));
          },
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.dry_cleaning_sharp), label: "Chores", key: Key("choresPage")),
            BottomNavigationBarItem(icon: Icon(Icons.monetization_on), label: "Finance"),
            BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Shopping"),
            BottomNavigationBarItem(icon: Icon(Icons.health_and_safety), label: "Medical")
          ],
        ));
  }

  Future<void> groupDetails(BuildContext context) async {
    //Checks screen size to see if it is mobile or desktop
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    final brightness = Theme.of(context).brightness;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Consumer<GroupViewModel>(builder: (context, viewModel, child) {
            return AlertDialog(
              scrollable: true,
              //Group name
              title: SizedBox(
                width: double.maxFinite,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: FutureBuilder<String?>(
                          future: viewModel.returnGroupName(user!.uid),
                          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                            if ("${snapshot.data}" == "null") {
                              return const Text(""); //Due to a delay in the data loading
                            } else {
                              return Expanded(
                                // flex: 2,
                                child: Align(
                                  alignment: Alignment.center,
                                  child: Text("${snapshot.data}",
                                      style: TextStyle(
                                          fontSize: isMobile ? 24 : 42,
                                          fontWeight: FontWeight.bold,
                                          color: AppColours.colour4(brightness))),
                                ),
                              );
                            }
                          }),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FutureBuilder<String?>(
                          future: viewModel.returnGroupCode(user!.uid),
                          builder: (BuildContext context, AsyncSnapshot<String?> snapshot) {
                            if ("${snapshot.data}" == "null") {
                              return const Text(""); //Due to a delay in the group code loading
                            } else {
                              return Expanded(
                                // flex: 1,
                                child: Text("Group Code: \n${snapshot.data}",
                                    style: TextStyle(
                                        fontSize: isMobile ? 14 : 24,
                                        fontWeight: FontWeight.bold,
                                        color: AppColours.colour4(brightness))),
                              );
                            }
                          }),
                    ),
                  ],
                ),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: double.maxFinite,
                  height: 400,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Form(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                  color: AppColours.colour2(brightness),
                                  borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                              padding: EdgeInsets.all(20),
                              child: ListView.separated(
                                  padding: EdgeInsets.all(15),
                                  separatorBuilder: (context, index) {
                                    return SizedBox(height: 15);
                                  },
                                  scrollDirection: Axis.vertical,
                                  physics: ScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: viewModel.memberIds.length,
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                        key: UniqueKey(),
                                        child: Container(
                                            decoration: BoxDecoration(
                                                color: AppColours.colour1(brightness),
                                                borderRadius: BorderRadius.circular(20)),
                                            child: ListTile(
                                              title: Row(
                                                children: [
                                                  Icon(Icons.account_box),
                                                  Text(viewModel.members[index],
                                                      style: TextStyle(
                                                          color: AppColours.colour4(brightness),
                                                          fontWeight: FontWeight.bold,
                                                          fontSize: 20)),
                                                ],
                                              ),
                                              // onTap: () =>
                                              //     viewSpecificUsersMedicalConditionsPopup(
                                              //         context, viewModel.memberIds[index]),
                                            )));
                                  }),
                            ),
                          ),

                          SizedBox(height: 20),

                          //Leave group button
                          ElevatedButton(
                              onPressed: () {
                                viewModel.leaveGroup(user!.uid);

                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => CreateOrJoinGroupPage()));
                              },
                              style: ElevatedButton.styleFrom(
                                  foregroundColor: AppColours.colour1(brightness),
                                  backgroundColor: AppColours.colour3(brightness),
                                  textStyle:
                                      const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20))),
                              child: const Text("Leave Group")),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          });
        });
  }
}
