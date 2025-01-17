class Expense {
  String expenseId;
  String expenseCreatorId;
  String name;
  double expenseAmount;
  List<String> assignedUsers;

  Expense({
    required this.expenseId,
    required this.expenseCreatorId,
    required this.name,
    required this.expenseAmount,
    required this.assignedUsers
});

  //Constructor for a new Expense
  Expense.newExpense(this.expenseCreatorId, this.name, this.expenseAmount, this.assignedUsers)
      : expenseId = '';

  // //Method that converts Group to a map for database storage
  // Map<String, dynamic> toMap() {
  //   return {
  //     'name': name,
  //     'members': members
  //   };
  // }
  //
  // //Factory constructor to create a Group from a Firestore document snapshot
  // factory Group.fromMap(String groupId, Map<String, dynamic> map) {
  //   return Group(
  //       groupId: groupId,
  //       name: map['name'],
  //       groupCode: map['groupCode'],
  //       members: List<String>.from(map['members'])
  //   );
  // }
}