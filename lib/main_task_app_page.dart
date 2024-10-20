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
  final int maxXP = 300; //Define maximum XP value
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
      () => TaskPage(
            tasks: tasks,
            onTasksChanged: _updateTasks,
            onGenerateSchedule: () => _generateSchedule(tasks), // Pass the callback here
          ),
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

  void _generateSchedule(List<Task> tasks) {
    setState(() {
      // Organize tasks into days based on available time and overflow
      organizedTasks = organizeTasksIntoDays(tasks, availableTimes);
      _selectedPageIndex = 1; // Switch to Current Schedule page index
    });
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
      bottom: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Height of the space for the progress bar
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0), // Add horizontal padding
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20.0), // Rounded corners
                child: LinearProgressIndicator(
                  value: totalXP / maxXP, // Calculate the progress
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  minHeight: 12, // Height of the progress bar
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4.0),
              child: Text(
                "XP: $totalXP / $maxXP",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    ),
    body: Column(
      children: [
        Expanded(
          child: _pages[_selectedPageIndex](),
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
      //body: _pages[_selectedPageIndex](),
    );
  }
}
