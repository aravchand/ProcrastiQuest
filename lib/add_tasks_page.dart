import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


class TaskEntryPage extends StatefulWidget {
  @override
  _TaskEntryPageState createState() => _TaskEntryPageState();
}

class _TaskEntryPageState extends State<TaskEntryPage> {
  @override
  Widget build(BuildContext context) {
    // Get the current week date range
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    String weekRange = "${DateFormat('MMM.').format(startOfWeek)} ${startOfWeek.day}-${endOfWeek.day}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Tasks for the week of $weekRange'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Center(
        child: Text('Task list will be displayed here'),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () => _showAddTaskModal(context),
            child: Icon(Icons.add),
          ),
          SizedBox(height: 8),
          Text("Add Task", style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
void _showAddTaskModal(BuildContext context) {
  TextEditingController _deadlineController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Task Description',
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Subject/Class',
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Priority',
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Duration (in minutes)',
                  ),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _deadlineController,
                  decoration: InputDecoration(
                    labelText: 'Deadline',
                  ),
                  readOnly: true, // Makes the TextField non-editable
                  onTap: () async {
                    DateTime? selectedDate = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2101),
                    );
                    if (selectedDate != null) {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (selectedTime != null) {
                        DateTime finalDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        // Format the final DateTime into a readable string
                        String formattedDateTime = DateFormat('yyyy-MM-dd – HH:mm').format(finalDateTime);
                        _deadlineController.text = formattedDateTime;
                      }
                    }
                  },
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // Handle saving the task
                    Navigator.pop(context);
                  },
                  child: Text('Save Task'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

}
