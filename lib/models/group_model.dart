class Group {
  String groupId;
  String name;
  List<String> members;

  Group({required this.groupId, required this.name, required this.members});

  //Method that converts Group to a map for database storage
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'members': members
    };
  }

  //Factory constructor to create a Group from a Firestore document snapshot
  factory Group.fromMap(String groupId, Map<String, dynamic> map) {
    return Group(
        groupId: groupId,
        name: map['name'],
        members: List<String>.from(map['members'])
    );
  }
}