import 'package:congress_app_challenge_24/enter_study_times_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:congress_app_challenge_24/task.dart';

// TaskPage - Create New Schedule
class TaskPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksChanged;

  TaskPage({required this.tasks, required this.onTasksChanged});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<int> availableTimes = List<int>.filled(7, 120); // Default study times, can be changed by user

  void _addTask() async {
    final Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog();
      },
    );

    if (newTask != null) {
      setState(() {
        widget.onTasksChanged([...widget.tasks, newTask]);
      });
    }
  }

  void _editTask(int index) async {
    final Task? updatedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(task: widget.tasks[index]);
      },
    );

    if (updatedTask != null) {
      setState(() {
        List<Task> updatedTasks = List.from(widget.tasks);
        updatedTasks[index] = updatedTask;
        widget.onTasksChanged(updatedTasks);
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      List<Task> updatedTasks = List.from(widget.tasks);
      updatedTasks.removeAt(index);
      widget.onTasksChanged(updatedTasks);
    });
  }

  void _goToStudyTimesPage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterStudyTimesPage(
          onTimesSubmitted: (times) {
            setState(() {
              availableTimes = times; // Update available times
            });
          },
        ),
      ),
    );
  }

  void _generateSchedule() {
    // Organize tasks into days based on available time and overflow
    Map<String, List<Task>> organizedTasks = organizeTasksIntoDays(widget.tasks, availableTimes);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrentSchedulePage(
          tasksByDay: organizedTasks, // Pass the organized tasks to the schedule page
          onTasksChanged: widget.onTasksChanged,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.tasks.isEmpty
          ? Center(child: Text('No tasks added yet.'))
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      task.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        SizedBox(height: 8.0),
                        Text('Priority: ${task.priority}'),
                        Text('Duration: ${task.duration} mins'),
                        Text('Due: ${task.dueDate}'),
                        Text('XP: ${task.duration * 50 / 30}'),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () => _editTask(index),
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _goToStudyTimesPage,
              child: Text("Set Study Times"),
            ),
            ElevatedButton(
              onPressed: _generateSchedule,
              child: Text("Generate Schedule"),
            ),
          ],
        ),
      ),
    );
  }
}

// Current Schedule Page
class CurrentSchedulePage extends StatefulWidget {
  final Map<String, List<Task>> tasksByDay;
  final Function(List<Task>) onTasksChanged;

  CurrentSchedulePage({required this.tasksByDay, required this.onTasksChanged});

  @override
  _CurrentSchedulePageState createState() => _CurrentSchedulePageState();
}

class _CurrentSchedulePageState extends State<CurrentSchedulePage> {
  // Update the checkbox state and notify changes
  void _toggleTaskCompletion(Task task) {
    setState(() {
      task.isCompleted = !task.isCompleted; // Toggle the completion state
    });
    // Notify the parent of the updated task list
    widget.onTasksChanged(widget.tasksByDay.values.expand((list) => list).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Schedule'),
        backgroundColor: Colors.purple[300],
      ),
      body: ListView(
        children: widget.tasksByDay.entries.map((entry) {
          return Card(
            margin: EdgeInsets.all(8.0),
            color: entry.key == 'Overflow' ? Colors.red[100] : Colors.yellow[100],
            child: ExpansionTile(
              title: Text(
                entry.key,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
              ),
              children: entry.value.map((task) {
                return ListTile(
                  leading: Checkbox(
                    value: task.isCompleted,
                    onChanged: (bool? value) {
                      _toggleTaskCompletion(task);
                    },
                  ),
                  title: Text(
                    task.name,
                    style: TextStyle(
                      decoration: task.isCompleted ? TextDecoration.lineThrough : null,
                    ),
                  ),
                  subtitle: Text('XP: ${Task.XP_of_ONE_SUBTASK} | Duration: ${task.duration} mins'),
                );
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// AddTaskDialog - Add/Edit Task Dialog
class AddTaskDialog extends StatefulWidget {
  final Task? task;

  AddTaskDialog({this.task});

  @override
  _AddTaskDialogState createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final _formKey = GlobalKey<FormState>();
  String _name = '';
  String _description = '';
  int _priority = 1;
  int _duration = 30;
  DateTime? _selectedDueDate;
  // int _xp = 50;
  final DateFormat _dateFormatter = DateFormat('yyyy-MM-dd HH:mm');
  final TextEditingController _dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _name = widget.task!.name;
      _description = widget.task!.description;
      _priority = widget.task!.priority;
      _duration = widget.task!.duration;
      _selectedDueDate = DateTime.tryParse(widget.task!.dueDate);
      // _xp = widget.task!.xp;
      if (_selectedDueDate != null) {
        _dueDateController.text = _dateFormatter.format(_selectedDueDate!);
      }
    }
  }

  @override
  void dispose() {
    _dueDateController.dispose();
    super.dispose();
  }

  void _showDatePicker() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Container(
          height: 250,
          child: CupertinoDatePicker(
            mode: CupertinoDatePickerMode.dateAndTime,
            initialDateTime: _selectedDueDate ?? DateTime.now(),
            onDateTimeChanged: (DateTime newDateTime) {
              setState(() {
                _selectedDueDate = newDateTime;
                _dueDateController.text = _dateFormatter.format(newDateTime);
              });
            },
            use24hFormat: true,
            minuteInterval: 1,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Add New Task' : 'Edit Task'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Task Name'),
                onSaved: (value) {
                  _name = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a task name';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _description,
                decoration: InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: InputDecoration(labelText: 'Priority (1-5)'),
                items: [1, 2, 3, 4, 5]
                    .map((priority) => DropdownMenuItem(
                          value: priority,
                          child: Text(priority.toString()),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _priority = value!;
                  });
                },
              ),
              TextFormField(
                initialValue: _duration.toString(),
                decoration: InputDecoration(labelText: 'Duration (in minutes)'),
                keyboardType: TextInputType.number,
                onSaved: (value) {
                  _duration = int.parse(value!);
                },
                validator: (value) {
                  if (value!.isEmpty || int.tryParse(value) == null) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              GestureDetector(
                onTap: _showDatePicker,
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _dueDateController,
                    decoration: InputDecoration(
                      labelText: 'Due Date',
                      hintText: 'Select Due Date',
                    ),
                  ),
                ),
              ),
              // DropdownButtonFormField<int>(
              //   value: _xp,
              //   decoration: InputDecoration(labelText: 'XP'),
              //   items: [50, 100, 200]
              //       .map((xp) => DropdownMenuItem(
              //             value: xp,
              //             child: Text('$xp XP'),
              //           ))
              //       .toList(),
              //   onChanged: (value) {
              //     setState(() {
              //       _xp = value!;
              //     });
              //   },
              // ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              _formKey.currentState!.save();
              final updatedTask = Task(
                name: _name,
                description: _description,
                priority: _priority,
                duration: _duration,
                dueDate: _selectedDueDate != null
                    ? _selectedDueDate!.toIso8601String()
                    : '',
                // xp: _xp,
              );
              Navigator.of(context).pop(updatedTask);
            }
          },
          child: Text('Submit'),
        ),
      ],
    );
  }
}

// Previous Tasks Page (Placeholder)
class PreviousTasksPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Previous Tasks'),
        backgroundColor: Colors.white, // Set AppBar background to default color
      ),
      body: Center(
        child: Text('This is the Previous Tasks page.'),
      ),
    );
  }
}
