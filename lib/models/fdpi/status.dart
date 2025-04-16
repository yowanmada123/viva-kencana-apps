class Status {
  final String id;
  final String name;

  Status({required this.id, required this.name});

  static List<Status> get statusList => [
        Status(id: 'Active', name: 'Active'),
        Status(id: 'Inactive', name: 'Inactive'),
      ];
}