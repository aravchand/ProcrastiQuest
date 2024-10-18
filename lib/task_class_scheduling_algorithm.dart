

// Task Model
class Task {
  static int XP_of_ONE_SUBTASK = 50;
  String name;
  String description;
  int priority;
  int duration;
  String dueDate;
  // int xp; // XP value for completing the task
  bool isCompleted; // Track if the task is completed or not
  int subtaskNumber; // Subtask number (e.g., 1 for "Subtask #1")

  Task({
    required this.name,
    required this.description,
    required this.priority,
    required this.duration,
    required this.dueDate,
    // required this.xp,
    this.isCompleted = false,
    this.subtaskNumber = 0, // Default is 0, which means not a subtask
  });
}

Map<String, List<Task>> organizeTasksIntoDays(List<Task> tasks, List<int> availableTimes) {
  tasks.sort((a, b) {
    int priorityCompare = a.priority.compareTo(b.priority);
    if (priorityCompare == 0) {
      return b.duration.compareTo(a.duration);
    }
    return priorityCompare;
  });

  Map<String, List<Task>> tasksByDay = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
    'Overflow': [],
  };

  List<String> days = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
  int dayIndex = 0;
  int maxInterval = 30; // Define max subtask interval as 30 minutes

  for (var task in tasks) {
    int remainingTime = task.duration;
    int subtaskNumber = 1; // Track each subtask number for display purposes

    while (remainingTime > 0 && dayIndex < 7) {
      int availableTimeForDay = availableTimes[dayIndex]; // PLAN is to REPLACE this with SHARED PREFERENCES
      int timeToPlace = (remainingTime > availableTimeForDay) ? availableTimeForDay : remainingTime;

      // Break the task into 30-minute chunks within the available time for the day
      while (timeToPlace > 0 && availableTimeForDay >= maxInterval) {
        tasksByDay[days[dayIndex]]!.add(
          Task(
            name: "${task.name} - Subtask #$subtaskNumber",
            description: task.description,
            priority: task.priority,
            duration: maxInterval,
            dueDate: task.dueDate,
            // xp: task.xp,
            subtaskNumber: subtaskNumber, // Track the subtask number
          ),
        );

        // Update for next chunk
        timeToPlace -= maxInterval;
        remainingTime -= maxInterval;
        availableTimeForDay -= maxInterval;
        availableTimes[dayIndex] -= maxInterval;
        subtaskNumber++;
      }

      // If there's remaining time that can't fit a full 30-minute chunk, move to the next day
      if (remainingTime > 0 && availableTimeForDay < maxInterval) {
        dayIndex++;
      }
    }

    // If there’s still remaining time, overflow it into the "Overflow" section
    if (remainingTime > 0) {
      while (remainingTime > 0) {
        int overflowTimeToPlace = (remainingTime > maxInterval) ? maxInterval : remainingTime;
        tasksByDay['Overflow']!.add(
          Task(
            name: "${task.name} - Subtask #$subtaskNumber",
            description: task.description,
            priority: task.priority,
            duration: overflowTimeToPlace,
            dueDate: task.dueDate,
            // xp: task.xp,
            subtaskNumber: subtaskNumber,
          ),
        );

        remainingTime -= overflowTimeToPlace;
        subtaskNumber++;
      }
    }
  }

  return tasksByDay;
}
