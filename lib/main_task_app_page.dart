import 'package:congress_app_challenge_24/settings_page.dart';
import 'package:flutter/material.dart'; 
import 'package:congress_app_challenge_24/test3.dart';
import 'package:intl/intl.dart';
import 'task.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData( 
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: TaskApp(),
    );
  }
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
  List<int> availableTimes = List<int>.filled(7, 120); // Default available time per day
  Map<String, int> dailyMinutes = {
    'Monday': 120,
    'Tuesday': 120,
    'Wednesday': 120,
    'Thursday': 120,
    'Friday': 120,
    'Saturday': 120,
    'Sunday': 120,
  };

  Map<String, List<Task>> organizedTasks = {}; // Store organized tasks by day

  final List<Widget Function()> _pages = []; // Remove the tasks parameter here

  @override
  void initState() {
    super.initState();
    // Initialize the pages, but we will handle the task assignment dynamically
    _pages.addAll([
      () => TaskPage(tasks: tasks, onTasksChanged: _updateTasks),
      () => CurrentSchedulePage(tasksByDay: organizedTasks, onTasksChanged: _updateTasks),
      () => PreviousTasksPage(),
    ]);
  }

  void _onDrawerItemTapped(int index) {
    setState(() {
      if (index == 1) {
        // If navigating to "Current Schedule", organize the tasks first
        organizedTasks = organizeTasksIntoDays(tasks, availableTimes);
      }
      _selectedPageIndex = index;
    });
    Navigator.of(context).pop(); // Close the drawer
  }

  void _updateTasks(List<Task> newTasks) {
    setState(() {
      tasks = newTasks;
      totalXP = newTasks.where((task) => task.isCompleted).fold(0, (sum, task) => sum + Task.XP_of_ONE_SUBTASK);
    });
  }

  void _updateDailyMinutes(Map<String, int> newDailyMinutes) {
    setState(() {
      dailyMinutes = newDailyMinutes;
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
      body: _pages[_selectedPageIndex](),
    );
  }
}
