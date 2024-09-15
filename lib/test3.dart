import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class TaskApp extends StatefulWidget {
  @override
  _TaskAppState createState() => _TaskAppState();
}

class _TaskAppState extends State<TaskApp> {
  int _selectedPageIndex = 0;
  
  final List<Widget> _pages = [
    TaskPage(),
    CurrentSchedulePage(),
    PreviousTasksPage(),
  ];

  void _onDrawerItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    DateTime startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    DateTime endOfWeek = startOfWeek.add(Duration(days: 6));
    String weekRange = "${DateFormat('MMM.').format(startOfWeek)} ${startOfWeek.day}-${endOfWeek.day}";

    return Scaffold(
      appBar: AppBar(
        // title: Text('Student Task App '),
        title: Text('Enter Tasks for the week of $weekRange'),
        backgroundColor: Colors.purple[300], // Set AppBar background to purple
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
      body: _pages[_selectedPageIndex],
    );
  }
}

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Task> tasks = [];

  void _addTask() async {
    final Task? newTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog();
      },
    );

    if (newTask != null) {
      setState(() {
        tasks.add(newTask);
      });
    }
  }

  void _editTask(int index) async {
    final Task editedTask = tasks[index];
    final Task? updatedTask = await showDialog<Task>(
      context: context,
      builder: (BuildContext context) {
        return AddTaskDialog(
          task: editedTask,
        );
      },
    );

    if (updatedTask != null) {
      setState(() {
        tasks[index] = updatedTask;
      });
    }
  }

  void _deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: tasks.isEmpty
          ? Center(child: Text('No tasks added yet.'))
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
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
                      ],
                    ),
                    isThreeLine: true,
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _editTask(index);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteTask(index);
                          },
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
    );
  }
}

class Task {
  String name;
  String description;
  int priority;
  int duration;
  String dueDate;

  Task({
    required this.name,
    required this.description,
    required this.priority,
    required this.duration,
    required this.dueDate,
  });
}

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
  String _dueDate = '';

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _name = widget.task!.name;
      _description = widget.task!.description;
      _priority = widget.task!.priority;
      _duration = widget.task!.duration;
      _dueDate = widget.task!.dueDate;
    }
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
              TextFormField(
                initialValue: _dueDate,
                decoration: InputDecoration(labelText: 'Due Date (YYYY-MM-DD)'),
                onSaved: (value) {
                  _dueDate = value!;
                },
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter a due date';
                  }
                  return null;
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
                dueDate: _dueDate,
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

// New pages for the Drawer

class CurrentSchedulePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Current Schedule'),
        backgroundColor: Colors.white, // Set AppBar background to default color
      ),
      body: Center(
        child: Text('This is the Current Schedule page.'),
      ),
    );
  }
}

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
