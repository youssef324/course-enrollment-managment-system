import 'dart:convert';
import 'dart:io';

class Student {
  String name;
  String email;
  String id;
  int phoneNumber;
  List enrollments;

  Student({required this.name, required this.email, required this.id, required this.phoneNumber, required this.enrollments});
  Studet({});
  

  double getGPA() {
    double totalPoints = 0.0;
    int totalCourses = enrollments.length;

    for (var enrollment in enrollments) {
      totalPoints += enrollment['grade'];
    }

    return totalCourses > 0 ? totalPoints / totalCourses : 0.0;
  }
  String toString() {
    return 'Name: $name, Email: $email, ID: $id, Phone: $phoneNumber, Enrollments: $enrollments';
  }
  
}