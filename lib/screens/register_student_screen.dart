import 'package:flutter/material.dart';
import '../model/student.dart';

class RegisterStudentScreen extends StatefulWidget {
  final List<Student> students;

  const RegisterStudentScreen({required this.students});

  @override
  _RegisterStudentScreenState createState() =>
      _RegisterStudentScreenState();
}

class _RegisterStudentScreenState extends State<RegisterStudentScreen> {
  final idController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final majorController = TextEditingController();

  void registerStudent() {
    widget.students.add(Student(
      id: idController.text,
      name: nameController.text,
      email: emailController.text.isEmpty ? null : emailController.text,
      major: majorController.text,
    ));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Student Registered Successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Register Student")),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(controller: idController, decoration: InputDecoration(labelText: "Student ID")),
            TextField(controller: nameController, decoration: InputDecoration(labelText: "Name")),
            TextField(controller: emailController, decoration: InputDecoration(labelText: "Email (Optional)")),
            TextField(controller: majorController, decoration: InputDecoration(labelText: "Major")),
            SizedBox(height: 20),
            ElevatedButton(onPressed: registerStudent, child: Text("Register")),
          ],
        ),
      ),
    );
  }
}
