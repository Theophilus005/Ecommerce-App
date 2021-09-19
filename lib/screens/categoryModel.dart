class CategoryModel {
  final String category;
  final int number;
  final int orders;
  final String imageUrl;
  final String ref;

  CategoryModel(
      {this.category, this.number, this.orders, this.imageUrl, this.ref});

  CategoryModel.fromFirestore(Map<String, dynamic> firestore)
      : category = firestore['category name'],
        number = firestore['Number'],
        orders = firestore['Orders'],
        imageUrl = firestore['imageUrl'],
        ref = firestore['ref'];
}
