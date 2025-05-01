class HouseSyncUser {
  String userId;
  String username;
  String email;
  String? groupId;
  List<String> assignedTasks;
  List<String> assignedExpenses;

  HouseSyncUser({
    required this.userId,
    required this.username,
    required this.email,
    required this.assignedTasks,
    required this.assignedExpenses,
    this.groupId,
  });

  //Constructor for a new User
  HouseSyncUser.newUser(this.username, this.email)
      : userId = '',
        groupId = '',
        assignedTasks = [],
        assignedExpenses = [];
}
