// Task Model
class Task {
  String name;
  String description;
  int priority;
  int duration;
  String dueDate;
  int xp; // XP value for completing the task
  bool isCompleted; // Track if the task is completed or not
  int subtaskNumber; // Subtask number (e.g., 1 for "Subtask #1")

  Task({
    required this.name,
    required this.description,
    required this.priority,
    required this.duration,
    required this.dueDate,
    required this.xp,
    this.isCompleted = false,
    this.subtaskNumber = 0, // Default is 0, which means not a subtask
  });
}

// Function to organize tasks into days and handle overflow
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

  for (var task in tasks) {
    int remainingTime = task.duration;
    int subtaskNumber = 1; // Start subtask numbering from 1 for each task

    while (remainingTime > 0 && dayIndex < 7) {
      int availableTimeForDay = availableTimes[dayIndex];
      int timeToPlace = (remainingTime > availableTimeForDay) ? availableTimeForDay : remainingTime;

      // Add the subtask with subtask number to the day
      tasksByDay[days[dayIndex]]!.add(
        Task(
          name: "${task.name} - Subtask #$subtaskNumber",
          description: task.description,
          priority: task.priority,
          duration: timeToPlace,
          dueDate: task.dueDate,
          xp: task.xp,
          subtaskNumber: subtaskNumber, // Track the subtask number
        ),
      );

      remainingTime -= timeToPlace;
      availableTimes[dayIndex] -= timeToPlace;
      subtaskNumber++; // Increment subtask number for the next part of the task

      // Move to the next day if the current day is full
      if (availableTimes[dayIndex] == 0) {
        dayIndex++;
      }
    }

    // If there's still remaining time for the task, put the rest in Overflow
    if (remainingTime > 0) {
      tasksByDay['Overflow']!.add(
        Task(
          name: "${task.name} - Subtask #$subtaskNumber",
          description: task.description,
          priority: task.priority,
          duration: remainingTime,
          dueDate: task.dueDate,
          xp: task.xp,
          subtaskNumber: subtaskNumber,
        ),
      );
    }
  }

  return tasksByDay;
}
