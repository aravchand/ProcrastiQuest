import 'package:flutter/material.dart'; 

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
