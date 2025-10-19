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

      void addStudent() {
  println('\n--- Add Student ---');
  final name = nonEmpty(readLine('Name: '));
  final email = nonEmpty(readLine('Email: ')).toLowerCase();
  if (studentEmails.contains(email)) {
    println('A student with this email already exists. Aborting.');
    return;
  }
  final phone = readLine('Phone (optional):').trim();
  final id = nextId();
  final s = Student(id: id, name: name, email: email, phoneNumber: phone.isEmpty ? null : phone);
  studentsById[id] = s;
  studentEmails.add(email);
  println('Added student: ${s}');
}

void editStudent() {
  println('\n--- Edit Student ---');
  final id = readLine('Student ID:').trim();
  if (!studentsById.containsKey(id)) {
    println('Student not found.');
    return;
  }
  final s = studentsById[id]!;
  println('Editing: ${s}');
  final newName = readLine('New name (leave blank to keep):').trim();
  final newEmail = readLine('New email (leave blank to keep):').trim();
  final newPhone = readLine('New phone (leave blank to keep / "null" to clear):').trim();

  if (newName.isNotEmpty) s.name = newName;
  if (newEmail.isNotEmpty) {
    final lower = newEmail.toLowerCase();
    if (lower != s.email && studentEmails.contains(lower)) {
      println('Email already used by another student. Skip email update.');
    } else {
      studentEmails.remove(s.email);
      s.email = lower;
      studentEmails.add(lower);
    }
  }
  if (newPhone.isNotEmpty) {
    if (newPhone.toLowerCase() == 'null') {
      s.phoneNumber = null;
    } else {
      s.phoneNumber = newPhone;
    }
  }
  println('Updated: ${s}');
}

void deleteStudent() {
  println('\n--- Delete Student ---');
  final id = readLine('Student ID:').trim();
  final s = studentsById.remove(id);
  if (s == null) {
    println('Student not found.');
    return;
  }
  // remove from sets and enrollments
  studentEmails.remove(s.email);
  for (var e in s.enrollments.toList()) {
    e.course.enrollments.remove(e);
  }
  println('Deleted student ${s.name} ($id).');
}
}