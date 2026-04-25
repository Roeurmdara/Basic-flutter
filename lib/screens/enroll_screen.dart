import 'package:flutter/material.dart';
import '../model/student.dart';
import '../model/course.dart';
import '../model/enrollment.dart';

class EnrollScreen extends StatefulWidget {
  final List<Student> students;
  final List<Course> courses;
  final List<Enrollment> enrollments;

  const EnrollScreen({
    required this.students,
    required this.courses,
    required this.enrollments,
  });

  @override
  _EnrollScreenState createState() => _EnrollScreenState();
}

class _EnrollScreenState extends State<EnrollScreen> {
  String? selectedStudent;
  String? selectedCourse;

  void enroll() {
    if (selectedStudent != null && selectedCourse != null) {
      widget.enrollments.add(
        Enrollment(
          studentId: selectedStudent!,
          courseId: selectedCourse!,
        ),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Enrollment Successful")),
      );

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enroll Student")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: Text("Select Student"),
              items: widget.students
                  .map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text("${s.id} - ${s.name}"),
                      ))
                  .toList(),
              onChanged: (value) => selectedStudent = value,
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              hint: Text("Select Course"),
              items: widget.courses
                  .map((c) => DropdownMenuItem(
                        value: c.courseId,
                        child: Text("${c.courseId} - ${c.courseName}"),
                      ))
                  .toList(),
              onChanged: (value) => selectedCourse = value,
            ),
            SizedBox(height: 20),
            ElevatedButton(onPressed: enroll, child: Text("Enroll")),
          ],
        ),
      ),
    );
  }
}
