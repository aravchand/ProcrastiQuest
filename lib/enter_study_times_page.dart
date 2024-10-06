import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EnterStudyTimesPage extends StatefulWidget {
  final Function(List<int>) onTimesSubmitted;

  EnterStudyTimesPage({required this.onTimesSubmitted});

  @override
  _EnterStudyTimesPageState createState() => _EnterStudyTimesPageState();
}

class _EnterStudyTimesPageState extends State<EnterStudyTimesPage> {
  List<int> _studyTimes = List<int>.filled(7, 120); // Default to 120 minutes for each day

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Study Times'),
      ),
      body: ListView.builder(
        itemCount: 7,
        itemBuilder: (context, index) {
          String day = DateFormat('EEEE').format(DateTime.now().add(Duration(days: index - DateTime.now().weekday + 1)));
          return ListTile(
            title: Text('$day:'),
            trailing: SizedBox(
              width: 100,
              child: TextFormField(
                keyboardType: TextInputType.number,
                initialValue: _studyTimes[index].toString(),
                onChanged: (value) {
                  _studyTimes[index] = int.tryParse(value) ?? _studyTimes[index];
                },
                decoration: InputDecoration(suffixText: 'minutes'),
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            widget.onTimesSubmitted(_studyTimes); // Pass the entered study times back
            Navigator.pop(context);
          },
          child: Text('Submit Study Times'),
        ),
      ),
    );
  }
}
