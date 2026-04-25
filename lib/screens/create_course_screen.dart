import 'package:flutter/material.dart';
import '../model/course.dart';

class CreateCourseScreen extends StatefulWidget {
  final List<Course> courses;

  const CreateCourseScreen({required this.courses});

  @override
  _CreateCourseScreenState createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final creditsController = TextEditingController();

  void createCourse() {
    widget.courses.add(
      Course(
        courseId: idController.text,
        courseName: nameController.text,
        credits: int.tryParse(creditsController.text) ?? 0,
      ),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Course Created Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Create Course")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: idController,
                decoration: InputDecoration(labelText: "Course ID")),
            TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: "Course Name")),
            TextField(
                controller: creditsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Credits")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: createCourse, child: Text("Create")),
          ],
        ),
      ),
    );
  }
}
