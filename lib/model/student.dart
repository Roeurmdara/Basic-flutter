class Student {
  String id;
  String name;
  String? email;
  String major;

  Student({
    required this.id,
    required this.name,
    this.email,
    required this.major,
  });
}
