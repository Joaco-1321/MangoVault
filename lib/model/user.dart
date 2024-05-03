class User {
  final String username;
  final Set<String> friends;

  User(this.username, {Set<String>? friends}) : friends = friends ?? {};
}