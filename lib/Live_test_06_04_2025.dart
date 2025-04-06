void main() {
  List<Map<String, dynamic>> students = [
    {"name": "Alice", "scores": [85, 90, 78]},
    {"name": "Bob", "scores": [88, 76, 95]},
    {"name": "Charlie", "scores": [90, 92, 85]}
  ];
  Map<String, double> average_score = {};
  for (var student in students) {
    List<int> scores = List<int>.from(student['scores']);
    double average = scores.reduce((a, b) => a + b) /
        scores.length;
    average_score[student['name']] = double.parse(average.toStringAsFixed(2));
  };
  var sorted_average_score = average_score.entries.toList()
  ..sort((a, b) => b.value.compareTo(a.value));
  
  print(Map.fromEntries(sorted_average_score));
  
}

