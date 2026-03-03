class UserModel {
  String? userId;
  String? name;
  String? email;
  String? phone;
  String? userType;
  String? profileImage;

  UserModel(
      {this.userId,
      this.name,
      this.email,
      this.phone,
      this.userType,
      this.profileImage});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json["userId"],
      name: json["name"],
      email: json["email"],
      phone: json["phone"],
      userType: json["userType"],
      profileImage: json["profileImage"],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "userId": userId,
      "name": name,
      "email": email,
      "phone": phone,
      "userType": userType,
      "profileImage": profileImage,
    };
  }
}
