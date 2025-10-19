class Course {
  final String courseCode;
  String courseName;
  int creditHours;
  final List<Enrollment> enrollments = [];

  Course({
    required this.courseCode,
    required this.courseName,
    required this.creditHours,
  });

  double get averageGrade {
    final graded = enrollments.where((e) => e.grade != Grade.None).toList();
    if (graded.isEmpty) return 0.0;
    final sum = graded.fold<double>(0.0, (p, e) => p + e.grade.value);
    return double.parse((sum / graded.length).toStringAsFixed(2));
  }

  @override
  String toString() => '[$courseCode] $courseName — $creditHours CH';

  
void addCourse() {
  println('\n--- Add Course ---');
  final code = nonEmpty(readLine('Course code (unique):')).toUpperCase();
  if (coursesByCode.containsKey(code)) {
    println('Course code already exists. Aborting.');
    return;
  }
  final name = nonEmpty(readLine('Course name:'));
  final chStr = nonEmpty(readLine('Credit hours (integer):'));
  try {
    final ch = int.parse(chStr);
    final c = Course(courseCode: code, courseName: name, creditHours: ch);
    coursesByCode[code] = c;
    println('Added course: ${c}');
  } catch (e) {
    println('Invalid credit hours. Aborting.');
  }
}

void editCourse() {
  println('\n--- Edit Course ---');
  final code = readLine('Course code:').trim().toUpperCase();
  final c = coursesByCode[code];
  if (c == null) {
    println('Course not found.');
    return;
  }
  println('Editing: ${c}');
  final newName = readLine('New name (leave blank to keep):').trim();
  final newCh = readLine('New credit hours (leave blank to keep):').trim();
  if (newName.isNotEmpty) c.courseName = newName;
  if (newCh.isNotEmpty) {
    try {
      c.creditHours = int.parse(newCh);
    } catch (e) {
      println('Invalid credit hours. Keeping old value.');
    }
  }
  println('Updated: ${c}');
}

void deleteCourse() {
  println('\n--- Delete Course ---');
  final code = readLine('Course code:').trim().toUpperCase();
  final c = coursesByCode.remove(code);
  if (c == null) {
    println('Course not found.');
    return;
  }
  for (var e in c.enrollments.toList()) {
    e.student.enrollments.remove(e);
  }
  println('Deleted course ${c.courseCode}.');
}

void enrollStudentInCourse() {
  println('\n--- Enroll Student in Course ---');
  final sid = readLine('Student ID:').trim();
  final s = studentsById[sid];
  if (s == null) {
    println('Student not found.');
    return;
  }
  final code = readLine('Course code:').trim().toUpperCase();
  final c = coursesByCode[code];
  if (c == null) {
    println('Course not found.');
    return;
  }
  // prevent duplicates
  final exists = s.enrollments.any((e) => e.course.courseCode == code);
  if (exists) {
    println('Student already enrolled in this course.');
    return;
  }
  final e = Enrollment(student: s, course: c);
  s.enrollments.add(e);
  c.enrollments.add(e);
  println('Enrolled ${s.name} in ${c.courseCode}.');
}

void assignOrUpdateGrade() {
  println('\n--- Assign / Update Grade ---');
  final sid = readLine('Student ID:').trim();
  final s = studentsById[sid];
  if (s == null) {
    println('Student not found.');
    return;
  }
  final code = readLine('Course code:').trim().toUpperCase();
  final enrollment = s.enrollments.firstWhere(
      (e) => e.course.courseCode == code,
      orElse: () => null);
  if (enrollment == null) {
    println('Student is not enrolled in that course.');
    return;
  }
  println('Current grade: ${enrollment.grade == Grade.None ? 'Not assigned' : enrollment.grade.name}');
  final gradeInput = nonEmpty(readLine('Enter grade (A,B,C,D,F) or "clear" to remove:')).trim();
  if (gradeInput.toLowerCase() == 'clear') {
    enrollment.grade = Grade.None;
    println('Grade cleared.');
    return;
  }
  final g = Grade.fromString(gradeInput);
  if (g == null || g == Grade.None) {
    println('Invalid grade input.');
    return;
  }
  enrollment.grade = g;
  println('Assigned grade ${g.name} to ${s.name} for ${code}.');
}

void viewAllStudentsAndCourses() {
  println('\n--- All Students & Their Enrollments ---');
  if (studentsById.isEmpty) {
    println('No students.');
  } else {
    for (var s in studentsById.values) {
      println(s.toString());
      if (s.enrollments.isEmpty) {
        println('  No enrollments.');
      } else {
        for (var e in s.enrollments) {
          final gradeLabel = e.grade == Grade.None ? 'Not assigned' : e.grade.name;
          println('  - ${e.course.courseCode} : ${e.course.courseName} — ${colorForGrade(e.grade, gradeLabel)}');
        }
      }
    }
  }

  println('\n--- All Courses & Rosters ---');
  if (coursesByCode.isEmpty) {
    println('No courses.');
  } else {
    for (var c in coursesByCode.values) {
      println(c.toString());
      if (c.enrollments.isEmpty) {
        println('  No students enrolled.');
      } else {
        for (var e in c.enrollments) {
          println('  - ${e.student.name} (${e.student.id}) — ${e.grade == Grade.None ? 'Not graded' : e.grade.name}');
        }
      }
    }
  }
}

void viewCourseStatistics() {
  println('\n--- Course Statistics ---');
  if (coursesByCode.isEmpty) {
    println('No courses to show.');
    return;
  }
  final code = readLine('Course code (or leave blank to view all):').trim().toUpperCase();
  if (code.isEmpty) {
    for (var c in coursesByCode.values) {
      println('${c.courseCode} — ${c.courseName}');
      println('  Total students: ${c.enrollments.length}');
      println('  Average grade (GPA scale): ${c.averageGrade.toStringAsFixed(2)}');
      final top = c.enrollments.where((e) => e.grade != Grade.None).toList()
        ..sort((a, b) => b.grade.value.compareTo(a.grade.value));
      if (top.isNotEmpty) {
        println('  Top graded student(s): ${top.first.student.name} (${top.first.grade.name})');
      } else {
        println('  No graded students yet.');
      }
    }
  } else {
    final c = coursesByCode[code];
    if (c == null) {
      println('Course not found.');
      return;
    }
    println('${c.courseCode} — ${c.courseName}');
    println('  Total students: ${c.enrollments.length}');
    println('  Average grade (GPA scale): ${c.averageGrade.toStringAsFixed(2)}');
    if (c.enrollments.isEmpty) {
      println('  No students enrolled.');
    } else {
      println('  Roster:');
      for (var e in c.enrollments) {
        println('   - ${e.student.name} (${e.student.id}) — ${e.grade == Grade.None ? 'Not graded' : e.grade.name}');
      }
    }
  }
}

void searchByStudentOrCourse() {
  println('\n--- Search ---');
  final q = nonEmpty(readLine('Enter student name (partial) or course code:')).trim();
  // search students by name partial match
  final foundStudents = studentsById.values.where((s) => s.name.toLowerCase().contains(q.toLowerCase())).toList();
  if (foundStudents.isNotEmpty) {
    println('Found students:');
    for (var s in foundStudents) println(' - ${s}');
  } else {
    println('No students found by that name.');
  }
  // search course by code exact
  final code = q.toUpperCase();
  if (coursesByCode.containsKey(code)) {
    final c = coursesByCode[code]!;
    println('\nFound course: ${c}');
    println('Roster (${c.enrollments.length}):');
    for (var e in c.enrollments) {
      println(' - ${e.student.name} (${e.student.id}) — ${e.grade == Grade.None ? 'Not graded' : e.grade.name}');
    }
  }
}

}