class Book {
  final String id;
  final String title;
  final String type;
  final double price;
  final Publisher? publisher;
  final Author? author;

  Book({
    required this.id,
    required this.title,
    required this.type,
    required this.price,
    this.publisher,
    this.author,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      price: (json['price'] ?? 0).toDouble(),
      publisher: json['publisher'] != null ? Publisher.fromJson(json['publisher']) : null,
      author: json['author'] != null ? Author.fromJson(json['author']) : null,
    );
  }
}

class Author {
  final String id;
  final String firstName;
  final String lastName;
  final String country;
  final String city;
  final String address;

  Author({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.country,
    required this.city,
    required this.address,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      id: json['_id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      country: json['country'] ?? '',
      city: json['city'] ?? '',
      address: json['address'] ?? '',
    );
  }

  String get fullName => '$firstName $lastName';
}

class Publisher {
  final String id;
  final String name;
  final String city;

  Publisher({
    required this.id,
    required this.name,
    required this.city,
  });

  factory Publisher.fromJson(Map<String, dynamic> json) {
    return Publisher(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      city: json['city'] ?? '',
    );
  }
}
