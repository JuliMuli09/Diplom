class UserModel {
  static String name = '';
  static String email = '';

  static void setUser(String userName, String userEmail) {
    name = userName;
    email = userEmail;
  }

  static void clear() {
    name = '';
    email = '';
  }
}