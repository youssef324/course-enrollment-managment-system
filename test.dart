// Save as cems.dart and run with: dart run cems.dart

import 'dart:convert';
import 'dart:io';

enum Grade {
  A(4.0),
  B(3.0),
  C(2.0),
  D(1.0),
  F(0.0),
  None(-1.0); // internal sentinel for no grade assigned

  final double value;
  const Grade(this.value);

  static Grade? fromString(String s) {
    final normalized = s.trim().toUpperCase();
    for (var g in Grade.values) {
      if (g.name == normalized) return g;
    }
    return null;
  }
}

String colorForGrade(Grade g, String text) {
  // ANSI colors: green=A, yellow=B/C/D, red=F, reset
  const reset = '\x1B[0m';
  if (g == Grade.A) return '\x1B[32m$text$reset'; // green
  if (g == Grade.F) return '\x1B[31m$text$reset'; // red
  if (g == Grade.None) return '\x1B[90m$text$reset'; // grey
  return '\x1B[33m$text$reset'; // yellow-ish for B/C/D
}

class Student {
  final String id;
  String name;
  String email;
  String? phoneNumber;
  final List<Enrollment> enrollments = [];

  Student({
    required this.id,
    required this.name,
    required this.email,
    this.phoneNumber,
  });

  double get gpa {
    final graded = enrollments.where((e) => e.grade != Grade.None).toList();
    if (graded.isEmpty) return 0.0;
    final sum = graded.fold<double>(0.0, (p, e) => p + e.grade.value);
    return double.parse((sum / graded.length).toStringAsFixed(2));
  }

  @override
  String toString() =>
      '[$id] $name — $email${phoneNumber != null ? ' (☎ $phoneNumber)' : ''} — GPA: ${gpa.toStringAsFixed(2)}';
}

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
}

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

void main() {
  showWelcome();
  while (true) {
    try {
      showMenu();
      final choice = readLine('Choose an option:').trim();
      if (choice.isEmpty) continue;
      switch (choice) {
        case '1':
          addStudent();
          break;
        case '2':
          editStudent();
          break;
        case '3':
          deleteStudent();
          break;
        case '4':
          addCourse();
          break;
        case '5':
          editCourse();
          break;
        case '6':
          deleteCourse();
          break;
        case '7':
          enrollStudentInCourse();
          break;
        case '8':
          assignOrUpdateGrade();
          break;
        case '9':
          viewAllStudentsAndCourses();
          break;
        case '10':
          viewCourseStatistics();
          break;
        case '11':
          searchByStudentOrCourse();
          break;
        case '12':
          sortStudentsMenu();
          break;
        case '13':
          exportReport();
          break;
        case '0':
          println('Exiting system. Bye.');
          return;
        default:
          println('Invalid option. Try again.');
      }
    } catch (e) {
      println('Error: $e');
    }
  }
}

void showWelcome() {
  println('=== Course Enrollment Management System (CEMS) ===');
  println('Console app — no GUI. Follow the menu.');
}

void showMenu() {
  println('\n--- Main Menu ---');
  println('1. Add Student');
  println('2. Edit Student');
  println('3. Delete Student');
  println('4. Add Course');
  println('5. Edit Course');
  println('6. Delete Course');
  println('7. Enroll Student in Course');
  println('8. Assign / Update Grade');
  println('9. View All Students & Courses');
  println('10. View Course Statistics');
  println('11. Search (student name or course code)');
  println('12. Sort students (by GPA or name)');
  println('13. Export report (text file)');
  println('0. Exit');
}



void sortStudentsMenu() {
  println('\n--- Sort Students ---');
  println('1. By GPA (desc)');
  println('2. By name (asc)');
  final pick = readLine('Pick:').trim();
  final list = studentsById.values.toList();
  if (list.isEmpty) {
    println('No students.');
    return;
  }
  if (pick == '1') {
    list.sort((a, b) => b.gpa.compareTo(a.gpa));
  } else {
    list.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }
  println('Sorted students:');
  for (var s in list) println(' - ${s}');
}

void exportReport() {
  println('\n--- Export Report ---');
  final filename = readLine('Filename (e.g., report.txt):').trim();
  if (filename.isEmpty) {
    println('No filename provided.');
    return;
  }
  final buffer = StringBuffer();
  buffer.writeln('CEMS REPORT — ${DateTime.now()}');
  buffer.writeln('\nStudents:');
  for (var s in studentsById.values) {
    buffer.writeln(s.toString());
    if (s.enrollments.isEmpty) {
      buffer.writeln('  No enrollments.');
    } else {
      for (var e in s.enrollments) {
        buffer.writeln('  - ${e.course.courseCode} : ${e.course.courseName} — ${e.grade == Grade.None ? 'Not assigned' : e.grade.name}');
      }
    }
  }
  buffer.writeln('\nCourses:');
  for (var c in coursesByCode.values) {
    buffer.writeln(c.toString());
    buffer.writeln('  Total students: ${c.enrollments.length}');
    buffer.writeln('  Average grade: ${c.averageGrade.toStringAsFixed(2)}');
  }

  try {
    final f = File(filename);
    f.writeAsStringSync(buffer.toString());
    println('Report written to $filename');
  } catch (e) {
    println('Failed to write file: $e');
  }
}

// Utility helpers

String readLine([String prompt = '']) {
  if (prompt.isNotEmpty) stdout.write('$prompt ');
  final line = stdin.readLineSync(encoding: utf8);
  return line ?? '';
}

String nonEmpty(String s) {
  final trimmed = s.trim();
  if (trimmed.isEmpty) {
    throw FormatException('Expected non-empty input.');
  }
  return trimmed;
}

void println(String s) {
  stdout.writeln(s);
}


