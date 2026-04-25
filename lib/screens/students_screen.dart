import 'package:flutter/material.dart';
import '../model/student.dart';

class StudentsScreen extends StatelessWidget {
  final List<Student> students;

  const StudentsScreen({required this.students});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("All Students")),
      body: students.isEmpty
          ? Center(child: Text("No students registered"))
          : ListView.builder(
              itemCount: students.length,
              itemBuilder: (context, index) {
                final s = students[index];
                return ListTile(
                  title: Text("${s.name} (${s.id})"),
                  subtitle: Text("Major: ${s.major}\nEmail: ${s.email ?? "N/A"}"),
                );
              },
            ),
    );
  }
}
