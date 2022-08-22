import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:table_calendar/table_calendar.dart';
import 'event.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'event.dart';

class Calendar extends StatefulWidget {
  @override
  State<Calendar> createState() => _CalendarState();
  var title = '';
  var description = '';
  var datetime = '';

  Calendar(
      {required this.title, required this.description, required this.datetime});
}

class _CalendarState extends State<Calendar> {
  late Map<DateTime, List<EventPage>> selectedEvents;

  CalendarFormat format = CalendarFormat.month;
  DateTime focusedDay = DateTime.now();
  DateTime selectedDay = DateTime.now();

  final CollectionReference _schoolCollection =
      FirebaseFirestore.instance.collection('schoolCollection');

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  List<EventPage> _getEventsfromDay(DateTime, date) {
    return selectedEvents[date] ?? [];
  }

  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Calendar"),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              TableCalendar(
                focusedDay: selectedDay,
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                calendarFormat: format,
                onFormatChanged: (CalendarFormat _format) {
                  setState(() {
                    format = _format;
                  });
                },
                startingDayOfWeek: StartingDayOfWeek.sunday,
                daysOfWeekVisible: true,
                //Day Changed
                onDaySelected: (DateTime selectDay, DateTime focusDay) {
                  setState(() {
                    selectedDay = selectDay;
                    focusedDay = focusDay;
                  });
                  print(focusedDay);
                },

                selectedDayPredicate: (DateTime date) {
                  return isSameDay(selectedDay, date);
                },

                //to style the calendar
                calendarStyle: const CalendarStyle(
                  isTodayHighlighted: true,
                  selectedDecoration: BoxDecoration(
                    color: Colors.purpleAccent,
                    shape: BoxShape.circle,
                  ),
                  selectedTextStyle: TextStyle(color: Colors.white),
                  todayDecoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                  defaultDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  weekendDecoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                ),

                headerStyle: HeaderStyle(
                  formatButtonVisible: true,
                  titleCentered: true,
                  formatButtonShowsNext: false,
                  formatButtonDecoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                  formatButtonTextStyle: const TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              //TODO   ..._getEventsfromDay(selectedDay,DateTime).map((EventPage event) => ListTile(title: Text(_eventController),),),

              SizedBox(
                height: 30.0,
              ),

              //Stream builder
              StreamBuilder(
                stream: _schoolCollection.snapshots(),
                builder:
                    (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                  if (streamSnapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: streamSnapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot documentSnapshot =
                            streamSnapshot.data!.docs[index];
                        return Card(
                          margin: const EdgeInsets.all(10),
                          child: ListTile(
                            title: Text(documentSnapshot['title']),
                            subtitle: Text(documentSnapshot['description']),
                            trailing: SizedBox(
                              width: 100,
                              child: Row(
                                children: [
                                  /*IconButton(
                                      icon: const Icon(Icons.edit),
                                      onPressed:
                                          () {}), // => _update(documentSnapshot)),
                               */
                                  IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () =>
                                          _delete(documentSnapshot.id)),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: Icon(Icons.add),
          label: Text("Add Event"),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => EventPage()),
            );
          },
        ));
  }

  Future<void> _delete(String productId) async {
    await _schoolCollection.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }
}
