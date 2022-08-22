import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class EventPage extends StatefulWidget {
  late final DateTime selecteDate;

  @override
  State<EventPage> createState() => _EventPageState();
}

class _EventPageState extends State<EventPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  TextEditingController _title = TextEditingController();
  TextEditingController _description = TextEditingController();
  TextEditingController _datetime = TextEditingController();

  final CollectionReference _schoolCollection =
      FirebaseFirestore.instance.collection('schoolCollection');

  DateTime selectedDay = DateTime.now();
  late Map<DateTime, List<EventPage>> selectedEvents;

  @override
  void initState() {
    selectedEvents = {};
    super.initState();
  }

  @override
  void dispose() {
    _title.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Events"),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.clear,
            color: Colors.redAccent,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          ElevatedButton(
              child: Text("save"),
              onPressed: () async {
                final String title = _title.text;
                final String description = _description.text;
                final double? datetime = double.tryParse(_datetime.text);
                if (title != null) {
                  await _schoolCollection.add({
                    "Title": title,
                    "Description": description,
                    "Datetime": datetime
                  });

                  _title.text = '';
                  _description.text = '';
                  _datetime.text = '';

                  Navigator.of(context).pop();
                }
              }),
          IconButton(
              onPressed: () {
                _update();
              },
              icon: Icon(Icons.edit)),
          IconButton(
              onPressed: () async {
                final confirm = await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              title: Text("Warning"),
                              content: Text("Are you sure you want to delete?"),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: Text("Delete")),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: Text(
                                      "Cancel",
                                      style: TextStyle(
                                          color: Colors.grey.shade700),
                                    ))
                              ],
                            )) ??
                    false;

                if (confirm) {
                  //
                }
              },
              icon: Icon(Icons.delete)),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(15.0),
        children: <Widget>[
          FormBuilder(
            child: Column(children: [
              FormBuilderTextField(
                name: "Title",
                controller: _title,
                decoration: InputDecoration(
                    hintText: "Add Title",
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.only(left: 48.0)),
              ),
              Divider(),
              FormBuilderTextField(
                name: "description",
                controller: _description,
                maxLines: 5,
                minLines: 1,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: "Add Details",
                  prefixIcon: Icon(Icons.short_text),
                ),
              ),
              Divider(),
              FormBuilderSwitch(
                name: "public",
                title: Text("Pubic"),
                initialValue: false,
                controlAffinity: ListTileControlAffinity.leading,
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
              Divider(),
              FormBuilderDateTimePicker(
                name: "date",
                controller: _datetime,
                initialValue: DateTime.now(),
                fieldHintText: "Add Date",
                inputType: InputType.date,
                //  format: Date
                decoration: InputDecoration(
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.calendar_today_sharp),
                ),
              )
            ]),
          ),
          SizedBox(
            height: 30.0,
          ),
          TextButton(
            onPressed: () async {
              DocumentSnapshot variable = await FirebaseFirestore.instance
                  .collection('schoolCollection')
                  .doc('tOTZ2vHQt0hIBXl6Ulbq')
                  .get();
              await FirebaseFirestore.instance
                  .collection('schoolCollection')
                  .get()
                  .then((querySnapshot) => {
                        querySnapshot.docs.forEach((element) {
                          print(element['schoolName']);
                        })
                      });
            },
            child: Text('Get Data'),
          ),
        ],
      ),
    );
  }

  Future<void> _update([DocumentSnapshot? documentSnapshot]) async {
    if (documentSnapshot != null) {
      _title.text = documentSnapshot['title'];
      _description.text = documentSnapshot['description'];
      _datetime.text = documentSnapshot['datetime'].toString();
    }

    await showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          return Padding(
            padding: EdgeInsets.only(
                top: 20,
                left: 20,
                right: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Title'),
                ),
                TextField(
                  controller: _description,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                  ),
                ),
                TextField(
                  controller: _datetime,
                  decoration: const InputDecoration(
                    labelText: 'DateTime',
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                ElevatedButton(
                  child: const Text('Update'),
                  onPressed: () async {
                    final String title = _title.text;
                    final String description = _description.text;

                    final double? datetime = double.tryParse(_datetime.text);
                    if (title != null) {
                      await _schoolCollection.doc(documentSnapshot!.id).update({
                        "Title": title,
                        "Description": description,
                        "DateTime": datetime,
                      });
                      _title.text = '';
                      _description.text = '';
                      _datetime.text = '';
                      Navigator.of(context).pop();
                    }
                  },
                )
              ],
            ),
          );
        });
  }

  Future<void> _delete(String productId) async {
    await _schoolCollection.doc(productId).delete();

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }
}
