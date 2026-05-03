/// iOS BlockedUser.swift 대응

class BlockedUserPage {
  final List<BlockedUser> blockedUsers;
  final int currentPage;
  final bool hasNext;

  const BlockedUserPage({
    required this.blockedUsers,
    required this.currentPage,
    required this.hasNext,
  });
}

class BlockedUser {
  final int id; // blockId
  final int userId;
  final String userName;
  final String createdAt;

  const BlockedUser({
    required this.id,
    required this.userId,
    required this.userName,
    required this.createdAt,
  });
}
