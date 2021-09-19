class MealModel {
  final String title;
  final String price;
  final String description;
  final String imageUrl;
  final String oldDoc;

  MealModel(
      {this.title, this.price, this.description, this.imageUrl, this.oldDoc});

  MealModel.fromFirebase(Map<String, dynamic> firestore)
      : title = firestore['title'],
        price = firestore['price'],
        description = firestore['decription'],
        imageUrl = firestore['imageUrl'],
        oldDoc = firestore['oldDoc'];
}
