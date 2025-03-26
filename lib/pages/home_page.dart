import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_accommodation_management_app/features/appbar_display.dart';
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

import '../models/event_model.dart';
import '../view_models/user_view_model.dart';
import '../views/home_page_views/home_header_view.dart';
import 'medical_page.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() {
    return _HomePageState();
  }
}

class _HomePageState extends State<HomePage> {
  int index = 0;
  List<Widget> pages = [
    HomePage(),
    ChoresPage(),
    FinancePage(),
    ShoppingPage(),
    MedicalPage()
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
    UserViewModel userViewModel = UserViewModel();

    final TextEditingController enteredEventNameController = TextEditingController();
    User? user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          children: [
            UserAccountsDrawerHeader(
              decoration: BoxDecoration(color: userViewModel.colour2),

              //User icon
              currentAccountPicture: const Expanded(
                  child: FittedBox(
                      fit: BoxFit.fitHeight,
                      child: Icon(Icons.account_circle_rounded))),

              //Username
              accountName: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentUsername(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(
                          ""); //Due to a delay in the username loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: userViewModel.colour4)),
                        ),
                      );
                    }
                  }),

              //Email
              accountEmail: FutureBuilder<String?>(
                  future: userViewModel.returnCurrentEmail(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    if ("${snapshot.data}" == "null") {
                      return const Text(
                          ""); //Due to a delay in the email loading
                    } else {
                      return Expanded(
                        child: FittedBox(
                          fit: BoxFit.fitHeight,
                          child: Text("${snapshot.data}",
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: userViewModel.colour4)),
                        ),
                      );
                    }
                  }),
            ),
            ListTile(
              title: Text("Group"),
              onTap: () => userViewModel.displayBottomSheet(
                  GroupDetailsBottomSheetView(), context),
            ),
            ListTile(title: Text("Settings")),
            ListTile(
                title: Text("Logout"),
                onTap: () async => await FirebaseAuth.instance.signOut().then(
                    (value) => Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (context) => LoginPage()),
                        (route) => false))),
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
              // Expanded(flex: 1, child: Container(color: Colors.green)),
              Expanded(flex: 5,
                  child: SingleChildScrollView(
                    child: TableCalendar(
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
                        }
                    ),
                  )
              ),
              SizedBox(height: 8.0),

              Expanded(
                flex: 3,
                  child: ValueListenableBuilder<List<Event>>(valueListenable: _selectedEvents, builder: (context, value, _) {
                    return Container(
                      decoration: BoxDecoration(
                          color: userViewModel.colour2,
                          borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
                      child: Column(
                        children: [
                          Text("Events",
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: userViewModel.colour4)
                          ),
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
                                return Container(
                                    decoration: BoxDecoration(
                                        color: homeViewModel.colour1,
                                        borderRadius: BorderRadius.circular(20)),
                                child: ListTile(
                                // onTap: () => print(''),
                                title: Text(value[index].title,
                                    style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: homeViewModel.colour4)),
                                  subtitle: Row(
                                    children: [
                                      Icon(Icons.access_time_outlined),
                                      Text(value[index].time.toString(),
                                          style: TextStyle(
                                              fontSize: 16,
                                              color: homeViewModel.colour4)),
                                    ],
                                  ),
                                ));
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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: Consumer<HomeViewModel>(builder: (context, viewModel, child) {
                  return SizedBox(
                    height: 60,
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            backgroundColor: viewModel.colour3,
                            foregroundColor: viewModel.colour1),
                        onPressed: () =>{
        if (_selectedDay != null) {
        viewModel.displayBottomSheet(
        Consumer<HomeViewModel>(builder: (context, viewModel, child) {
        return Padding(
        padding: EdgeInsets.only(
        bottom: MediaQuery.of(context)
            .viewInsets
            .bottom), //Ensures the keyboard doesn't cover the textfields
        child: Container(
        height: 100,
        padding: const EdgeInsets.all(16.0),
        child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
        TextField(
        decoration: const InputDecoration(
        hintText: "Event Name", border: OutlineInputBorder()),
        controller: enteredEventNameController,
        onSubmitted: (value) async {
        if (enteredEventNameController.text.isNotEmpty) {
        Event newEvent = Event.newEvent(user!.uid, enteredEventNameController.text, _focusedDay);

        TimeOfDay? selectedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now());

        viewModel.addCalendarEvent(newEvent, user.uid, selectedTime!);
        // events.addAll({_selectedDay! : [newEvent]});
        setState(() {
          if (events.containsKey(_selectedDay)) {
            events[_selectedDay]!.add(newEvent); //Adds the new event
          } else {
            events[_selectedDay!] = [newEvent]; // Creates new list with event
          }
        });
        enteredEventNameController.clear();
        }
        Navigator.of(context).pop(); //Makes bottom event bar disappear
          // _selectedEvents.value = _getEventsForDay(_selectedDay!);
          _loadEventsForDay(_selectedDay!);
        }
        ),
        ],
        )));
        }),

        context)
        } else {
          showToast(message: "Please Select A Day")
        }
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
            BottomNavigationBarItem(
                icon: Icon(Icons.home), label: "Home"),
            BottomNavigationBarItem(
                icon: Icon(Icons.dry_cleaning_sharp), label: "Chores"),
            BottomNavigationBarItem(
                icon: Icon(Icons.monetization_on), label: "Finance"),
            BottomNavigationBarItem(
                icon: Icon(Icons.shopping_cart), label: "Shopping"),
            BottomNavigationBarItem(
                icon: Icon(Icons.health_and_safety), label: "Medical")
          ],
        ));
  }
}
