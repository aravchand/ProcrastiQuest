import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Task Model
class Task {
  String name;
  String description;
  int priority;
  int duration;
  String dueDate;
  int xp; // XP value for completing the task
  bool isCompleted; // Track if the task is completed or not

  Task({
    required this.name,
    required this.description,
    required this.priority,
    required this.duration,
    required this.dueDate,
    required this.xp,
    this.isCompleted = false,
  });
}

// Main Task App
class TaskApp extends StatefulWidget {
  @override
  _TaskAppState createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  int _selectedPageIndex = 0;
  List<Task> tasks = [];
  int totalXP = 0; // Store total XP

  final List<Widget Function(List<Task>, void Function(List<Task>))> _pages = [
  (tasks, updateTasks) => TaskPage(tasks: tasks, onTasksChanged: updateTasks),
  (tasks, updateTasks) => CurrentSchedulePage(tasks: tasks, onTasksChanged: updateTasks),
  (tasks, updateTasks) => PreviousTasksPage(),
];


  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  void _updateTasks(List<Task> newTasks) {
    setState(() {
      tasks = newTasks;
      totalXP = newTasks.where((task) => task.isCompleted).fold(0, (sum, task) => sum + task.xp);
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    String weekRange = "${DateFormat('MMM.').format(startOfWeek)} ${startOfWeek.day} - ${endOfWeek.day}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Tasks: $weekRange'),
        backgroundColor: Colors.purple[300], // Set AppBar background to purple
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "XP: $totalXP",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.purple[200],
              ),
              child: Container(
                padding: EdgeInsets.zero,
                child: Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.add),
              title: Text('Create New Schedule'),
              onTap: () {
                _onDrawerItemTapped(0); // Go to Create New Schedule page
              },
            ),
            ListTile(
              leading: Icon(Icons.schedule),
              title: Text('Current Schedule'),
              onTap: () {
                _onDrawerItemTapped(1); // Go to Current Schedule page
              },
            ),
            ListTile(
              leading: Icon(Icons.history),
              title: Text('Previous Tasks'),
              onTap: () {
                _onDrawerItemTapped(2); // Go to Previous Tasks page
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex](tasks, _updateTasks),
    );
  }
}

// TaskPage - Create New Schedule
class TaskPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksChanged;

  TaskPage({required this.tasks, required this.onTasksChanged});

  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
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
                        Text('XP: ${task.xp}'),
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
        child: ElevatedButton(
          onPressed: () {
            widget.onTasksChanged(widget.tasks); // Passing the tasks
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CurrentSchedulePage(tasks: widget.tasks, onTasksChanged: widget.onTasksChanged)),
            );
          },
          child: Text("Generate Schedule"),
        ),
      ),
    );
  }
}

// Current Schedule Page
class CurrentSchedulePage extends StatelessWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksChanged;

  CurrentSchedulePage({required this.tasks, required this.onTasksChanged});

  @override
  Widget build(BuildContext context) {
    Map<String, List<Task>> tasksByDay = {
      'Monday': [],
      'Tuesday': [],
      'Wednesday': [],
      'Thursday': [],
      'Friday': [],
      'Saturday': [],
      'Sunday': [],
    };

    for (var task in tasks) {
      DateTime taskDate = DateTime.parse(task.dueDate);
      String day = DateFormat('EEEE').format(taskDate);
      if (tasksByDay.containsKey(day)) {
        tasksByDay[day]?.add(task);
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Current Schedule'),
        backgroundColor: Colors.purple[300],
      ),
      body: ListView(
        children: tasksByDay.entries.map((entry) {
          return Card(
            margin: EdgeInsets.all(8.0),
            color: Colors.yellow[100], // Aesthetic for post-it look
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
                      task.isCompleted = value ?? false;
                      onTasksChanged(tasks);
                    },
                  ),
                  title: Text(task.name),
                  subtitle: Text('XP: ${task.xp}'),
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
  int _xp = 50;
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
      _xp = widget.task!.xp;
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
              DropdownButtonFormField<int>(
                value: _xp,
                decoration: InputDecoration(labelText: 'XP'),
                items: [50, 100, 200]
                    .map((xp) => DropdownMenuItem(
                          value: xp,
                          child: Text('$xp XP'),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _xp = value!;
                  });
                },
              ),
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
                xp: _xp,
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
