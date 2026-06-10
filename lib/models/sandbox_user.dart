class SandboxUser {
  final int id;
  final String userId;
  final String emailAddress;
  final String nickName;
  final bool approved;
  final String? approvedAt;
  final bool admin;
  final bool blocked;
  final String createdAt;
  final String updatedAt;

  SandboxUser({
    required this.id,
    required this.userId,
    required this.emailAddress,
    required this.nickName,
    required this.approved,
    this.approvedAt,
    required this.admin,
    required this.blocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory SandboxUser.fromJson(Map<String, dynamic> json) => SandboxUser(
        id: json['id'] as int,
        userId: json['userId'] as String,
        emailAddress: json['emailAddress'] as String,
        nickName: json['nickName'] as String,
        approved: json['approved'] as bool,
        approvedAt: json['approvedAt'] as String?,
        admin: json['admin'] as bool,
        blocked: json['blocked'] as bool,
        createdAt: json['createdAt'] as String,
        updatedAt: json['updatedAt'] as String,
      );
}

sealed class LoginResult {}

class LoginSuccess extends LoginResult {}

class LoginNewAccount extends LoginResult {}

class LoginPendingApproval extends LoginResult {}

class LoginBlocked extends LoginResult {}
