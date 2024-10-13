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
  const TaskApp({super.key});

  @override
  _TaskAppState createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  int _selectedPageIndex = 0;
  List<Task> tasks = [];
  int totalXP = 0; // Store total XP
  Map<String, int> dailyMinutes = {
    'Monday': 0,
    'Tuesday': 0,
    'Wednesday': 0,
    'Thursday': 0,
    'Friday': 0,
    'Saturday': 0,
    'Sunday': 0,
  };

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

  void _updateDailyMinutes(Map<String, int> newMinutes) {
    setState(() {
      dailyMinutes = newMinutes;
    });
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(const Duration(days: 6));
    String weekRange = "${DateFormat('MMM.').format(startOfWeek)} ${startOfWeek.day} - ${endOfWeek.day}";

    return Scaffold(
      appBar: AppBar(
        title: Text('Enter Tasks: $weekRange'),
        backgroundColor: Colors.purple[300], // Set AppBar background to purple
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(
                "XP: $totalXP",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                child: const Text(
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
              leading: const Icon(Icons.add),
              title: const Text('Create New Schedule'),
              onTap: () {
                _onDrawerItemTapped(0); // Go to Create New Schedule page
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule),
              title: const Text('Current Schedule'),
              onTap: () {
                _onDrawerItemTapped(1); // Go to Current Schedule page
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Previous Tasks'),
              onTap: () {
                _onDrawerItemTapped(2); // Go to Previous Tasks page
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SettingsPage(
                      dailyMinutes: dailyMinutes,
                      onMinutesChanged: _updateDailyMinutes,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: _pages[_selectedPageIndex](tasks, _updateTasks),
    );
  }
}

// Settings Page for users to input minutes of tasks each day
class SettingsPage extends StatefulWidget {
  final Map<String, int> dailyMinutes;
  final Function(Map<String, int>) onMinutesChanged;

  const SettingsPage({super.key, required this.dailyMinutes, required this.onMinutesChanged});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Map<String, TextEditingController> controllers;

  @override
  void initState() {
    super.initState();
    controllers = {
      'Monday': TextEditingController(text: widget.dailyMinutes['Monday']?.toString() ?? '0'),
      'Tuesday': TextEditingController(text: widget.dailyMinutes['Tuesday']?.toString() ?? '0'),
      'Wednesday': TextEditingController(text: widget.dailyMinutes['Wednesday']?.toString() ?? '0'),
      'Thursday': TextEditingController(text: widget.dailyMinutes['Thursday']?.toString() ?? '0'),
      'Friday': TextEditingController(text: widget.dailyMinutes['Friday']?.toString() ?? '0'),
      'Saturday': TextEditingController(text: widget.dailyMinutes['Saturday']?.toString() ?? '0'),
      'Sunday': TextEditingController(text: widget.dailyMinutes['Sunday']?.toString() ?? '0'),
    };
  }
  
  @override
  void dispose() {
    controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }

  void _saveSettings() {
    Map<String, int> updatedMinutes = {};
    controllers.forEach((day, controller) {
      updatedMinutes[day] = int.tryParse(controller.text) ?? 0;
    });
    widget.onMinutesChanged(updatedMinutes);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.purple[300],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Set Daily Task Time (in minutes)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            for (var day in widget.dailyMinutes.keys) ...[
              TextField(
                controller: controllers[day],
                decoration: InputDecoration(
                  labelText: day,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16), // Spacing between each input
            ],
            const SizedBox(height: 16), // Additional bottom space for aesthetics
            ElevatedButton(
              onPressed: _saveSettings,
              child: const Text('Save Settings'),
            ),
          ],
        ),
      ),
    );
  }
}


// TaskPage - Create New Schedule
class TaskPage extends StatefulWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksChanged;

  const TaskPage({super.key, required this.tasks, required this.onTasksChanged});

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
          ? const Center(child: Text('No tasks added yet.'))
          : ListView.builder(
              itemCount: widget.tasks.length,
              itemBuilder: (context, index) {
                final task = widget.tasks[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      task.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(task.description),
                        const SizedBox(height: 8.0),
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
        child: const Icon(Icons.add),
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
          child: const Text("Generate Schedule"),
        ),
      ),
    );
  }
}

// Current Schedule Page
class CurrentSchedulePage extends StatelessWidget {
  final List<Task> tasks;
  final Function(List<Task>) onTasksChanged;

  const CurrentSchedulePage({super.key, required this.tasks, required this.onTasksChanged});

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
        title: const Text('Current Schedule'),
        backgroundColor: Colors.purple[300],
      ),
      body: ListView(
        children: tasksByDay.entries.map((entry) {
          return Card(
            margin: const EdgeInsets.all(8.0),
            color: Colors.yellow[100], // Aesthetic for post-it look
            child: ExpansionTile(
              title: Text(
                entry.key,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18.0),
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

  const AddTaskDialog({super.key, this.task});

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
        return SizedBox(
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
                decoration: const InputDecoration(labelText: 'Task Name'),
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
                decoration: const InputDecoration(labelText: 'Description'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(labelText: 'Priority (1-5)'),
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
                decoration: const InputDecoration(labelText: 'Duration (in minutes)'),
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
                    decoration: const InputDecoration(
                      labelText: 'Due Date',
                      hintText: 'Select Due Date',
                    ),
                  ),
                ),
              ),
              DropdownButtonFormField<int>(
                value: _xp,
                decoration: const InputDecoration(labelText: 'XP'),
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
          child: const Text('Cancel'),
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
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

// Previous Tasks Page (Placeholder)
class PreviousTasksPage extends StatelessWidget {
  const PreviousTasksPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Previous Tasks'),
        backgroundColor: Colors.white, // Set AppBar background to default color
      ),
      body: const Center(
        child: Text('This is the Previous Tasks page.'),
      ),
    );
  }
}

// Entry point of the app
void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TaskApp(),
  ));
}
