import 'package:flutter/material.dart';
import '../model/course.dart';
import '../model/enrollment.dart';

class CoursesScreen extends StatelessWidget {
  final List<Course> courses;
  final List<Enrollment> enrollments;

  const CoursesScreen({
    required this.courses,
    required this.enrollments,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Courses")),
      body: courses.isEmpty
          ? Center(child: Text("No courses available"))
          : ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final c = courses[index];
                final count = enrollments
                    .where((e) => e.courseId == c.courseId)
                    .length;

                return ListTile(
                  title: Text("${c.courseName} (${c.courseId})"),
                  subtitle: Text(
                      "Credits: ${c.credits}\nEnrolled Students: $count"),
                );
              },
            ),
    );
  }
}
