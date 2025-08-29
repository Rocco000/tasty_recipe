abstract class Entity {
  /// Convert entity to a Firestore-ready JSON map
  Map<String, dynamic> toJson();
}
