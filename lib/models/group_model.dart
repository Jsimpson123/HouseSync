class Group {
  String groupId;
  String name;
  String groupCode;
  List<String> members;

  Group(
      {required this.groupId, required this.name, required this.groupCode, required this.members});

  //Constructor for a new Group
  Group.newGroup(this.name)
      : groupId = '',
        groupCode = '',
        members = [];
}
