
class HouseSyncUser {
  String userId;
  String username;
  String email;
  String? groupId;
  List<String> assignedTasks;
  List<String> assignedExpenses;

  HouseSyncUser(
      {required this.userId,
      required this.username,
      required this.email,
        required this.assignedTasks,
        required this.assignedExpenses,
      this.groupId,});

  //Constructor for a new User
  HouseSyncUser.newUser(this.username, this.email)
      : userId = '',
        groupId = '',
        assignedTasks = [],
        assignedExpenses = [];

  //Method that converts User to a map for database storage
  Map<String, dynamic> toMap() {
    return {'username': username, 'email': email, 'groupId': groupId};
  }

  //Factory constructor to create a User from a Firestore document snapshot
  factory HouseSyncUser.fromMap(
      String userId, Map<String, dynamic> map) {
    return HouseSyncUser(
        userId: userId,
        username: map['username'],
        email: map['email'],
        groupId: map['groupId'],
        assignedTasks: List<String>.from(map['tasks']),
        assignedExpenses: List<String>.from(map['expenses'])
    );
  }
}
