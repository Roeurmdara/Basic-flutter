import 'package:flutter/material.dart';
import '../model/course.dart';
import '../model/student.dart';
import '../model/enrollment.dart';

class CourseStudentsScreen extends StatefulWidget {
  final List<Student> students;
  final List<Course> courses;
  final List<Enrollment> enrollments;

  const CourseStudentsScreen({
    required this.students,
    required this.courses,
    required this.enrollments,
  });

  @override
  _CourseStudentsScreenState createState() =>
      _CourseStudentsScreenState();
}

class _CourseStudentsScreenState extends State<CourseStudentsScreen> {
  String? selectedCourse;

  @override
  Widget build(BuildContext context) {
    final enrolledStudents = widget.enrollments
        .where((e) => e.courseId == selectedCourse)
        .map((e) =>
            widget.students.firstWhere((s) => s.id == e.studentId))
        .toList();

    return Scaffold(
      appBar: AppBar(title: Text("Course Students")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            DropdownButtonFormField<String>(
              hint: Text("Select Course"),
              items: widget.courses
                  .map((c) => DropdownMenuItem(
                        value: c.courseId,
                        child: Text("${c.courseId} - ${c.courseName}"),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCourse = value;
                });
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: enrolledStudents.isEmpty
                  ? Center(child: Text("No students enrolled"))
                  : ListView.builder(
                      itemCount: enrolledStudents.length,
                      itemBuilder: (context, index) {
                        final s = enrolledStudents[index];
                        return ListTile(
                          title: Text("${s.name} (${s.id})"),
                          subtitle: Text("Major: ${s.major}"),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
