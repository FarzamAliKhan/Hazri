// @dart=2.9

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'AttendanceScreen.dart';
import 'package:intl/intl.dart';


//implementation of Event Class
// which are events displayed on calendar UI

class Event {
  final String title;
  Event(this.title);

  @override
  String toString() {
    return title;
  }
}

class DateListScreen extends StatefulWidget {
  final String RoleType;
  const DateListScreen({Key key, @required this.RoleType}) : super(key: key);

  @override
  State<DateListScreen> createState() => _DateListScreenState();
}

class _DateListScreenState extends State<DateListScreen> {
  ValueNotifier<List<Event>> _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay));
    fetchDataAndPopulateEvents(events);
    ;
  }

  Future<void> fetchDataAndPopulateEvents(Map<DateTime, List<Event>> events) async {
    try {
      List<dynamic> dateList = await fetchDateListFromFirebase(); // Fetch date list from Firebase
      Map<DateTime, List<Event>> extractedEvents = await extractEventsFromFirebase(dateList,events);
      events.addAll(extractedEvents); // Add extracted events to the events map
      print('Events populated successfully');
      print('events after populating: $events');
    } catch (error) {
      print('Error fetching and populating events: $error');
    }
  }

   // Map to store events for each day
  Map<DateTime, List<Event>> events = {};

  List<Event> _getEventsForDay(DateTime day) {
    return events[day] ?? [];
  }


   @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      print("Selected Day: $selectedDay");
      print("Events for selected Day: ${_getEventsForDay(selectedDay)}");

      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _selectedEvents.value = _getEventsForDay(selectedDay);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.RoleType}',
          style: GoogleFonts.ubuntu(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: const Color(0xff508AA8),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
        ),
        shadowColor: Colors.blueGrey,
      ),
      body: FutureBuilder<List>(
        future: fetchDateListFromFirebase(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data.isEmpty) {
            return Center(child: Text('No dates found'));
          } else {
            List dateList = snapshot.data;
            print('datelist: $dateList');
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: TableCalendar<Event>(
                    availableCalendarFormats: const {CalendarFormat.month: 'Month'},
                    firstDay: DateTime.utc(2020, 10, 16),
                    lastDay: DateTime.utc(2025, 3, 14),
                    focusedDay: _focusedDay,
                    selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.monday,
                    calendarStyle: const CalendarStyle(
                      // Use `CalendarStyle` to customize the UI
                      outsideDaysVisible: false,

                    ),
                    onDaySelected: _onDaySelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      _focusedDay = focusedDay;
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Classes:", // Add your big title here
                    style: TextStyle(fontWeight: FontWeight.bold,
                fontSize: 24,),
                  ),
                ),
                  Expanded(
                    child: ValueListenableBuilder<List<Event>>(
                      valueListenable: _selectedEvents,
                      builder: (context, value, _) {
                        return ListView.builder(
                          itemCount: value.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 12.0,
                                vertical: 4.0,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xff508AA8),
                                borderRadius: BorderRadius.circular(12.0),
                              ),
                              child: ListTile(
                                onTap: () => {
                                if (widget.RoleType == "Edit Attendance") {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditAttendance(
                                        courseCode: 'SE-312',
                                        sessionDocumentId: 'session',
                                        selectedDate: '${value[index]}',
                                        roleType: "Edit Attendance",
                                      ),
                                    ),
                                  )
                                } else {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditAttendance(
                                        courseCode: 'SE-312',
                                        sessionDocumentId: 'session',
                                        selectedDate: '${value[index]}',
                                        roleType: "View Attendance",
                                      ),
                                    ),
                                  )
                                }
                              },
                                title: Text('${value[index]}',
                                      style: GoogleFonts.ubuntu(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,),
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
              ],
            );
          }
        },
      ),
    );
  }
}

Future<List> fetchDateListFromFirebase() async {
    try {
      QuerySnapshot<Map<String, dynamic>> snapshot =
          await FirebaseFirestore.instance
              .collection('attendance') // Your main collection
              .doc('SE-312') // Replace with your actual course code
              .collection('session') // Collection containing session documents
              .get();

      List dateList = snapshot.docs
          .map((doc) => (doc['date'] ))
          .toList();

      // Remove duplicate dates if needed
      dateList = dateList.toSet().toList();

      // Sort the dates in descending order
      dateList.sort((a, b) => b.compareTo(a));

      return dateList;
    } catch (error) {

      print('Error fetching date list: $error');
      throw error;
    }
  }

Future<Map<DateTime, List<Event>>> extractEventsFromFirebase(List<dynamic> dateList, Map<DateTime, List<Event>> events ) async {
  //creating a date format to convert date to a preset dd-MM-yyyy
  DateFormat dateFormat = DateFormat('dd-MM-yyyy');

  // Iterate over the list of date strings
  for (String dateItem in dateList.cast<String>()) {
      // Use a regular expression to extract the date part
      RegExp regex = RegExp(r'(\d{2}-\d{2}-\d{4})');
      Match match = regex.firstMatch(dateItem);

      if (match != null) {
        // Extract the date part from the first matched group
        String dateString = match.group(0);
        // Parse the date string into a DateTime object,
        DateTime dateTime = dateFormat.parse(dateString);
        //convert to utc time zone because our calendar only accepts utc events
        DateTime utcDateTime = DateTime.utc(dateTime.year, dateTime.month, dateTime.day,0,0,0,0);

        if (utcDateTime != null) {
          // Check if the date already exists in the events map
          if (events.containsKey(utcDateTime)) {
            // If the date exists, add a new Event with the time
            events[utcDateTime].add(Event(dateItem));
          } else {
            // If the date doesn't exist, create a new list with the Event
            events[utcDateTime] = [Event(dateItem)];
          }
        }
      }
  }
  return events;
}