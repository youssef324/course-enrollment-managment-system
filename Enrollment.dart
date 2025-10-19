class Enrollment {
  final Student student;
  final Course course;
  Grade grade;

  Enrollment({
    required this.student,
    required this.course,
    this.grade = Grade.None,
  });

  @override
  String toString() {
    final gradeLabel = grade == Grade.None ? 'Not assigned' : grade.name;
    final colored = colorForGrade(grade, gradeLabel);
    return '${student.name} (${student.id}) -> ${course.courseCode}: $colored';
  }
}

// In-memory storage
final Map<String, Student> studentsById = {};
final Map<String, Course> coursesByCode = {};
final Set<String> studentEmails = {};

String nextId() => DateTime.now().microsecondsSinceEpoch.toString();