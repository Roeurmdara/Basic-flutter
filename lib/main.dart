import 'package:flutter/material.dart';
import 'model/course.dart';
import 'model/enrollment.dart'; 
import 'model/student.dart';
import 'screens/home_screen.dart';






void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<Enrollment> enrollments = [];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student Registration System',
      home: HomeScreen(
        students: students,
        courses: courses,
        enrollments: enrollments,
      ),
    );
  }
}
