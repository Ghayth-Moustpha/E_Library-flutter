import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/book.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:34723/api';

  Map<String, String> _getHeaders({String? token}) {
    final headers = {'Content-Type': 'application/json'};
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  // Auth endpoints
  Future<String> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: _getHeaders(),
      body: jsonEncode({'username': username, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['token'];
    } else {
      throw Exception('Login failed');
    }
  }

  Future<void> signup(String username, String password, String firstName, String lastName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/signup'),
      headers: _getHeaders(),
      body: jsonEncode({
        'username': username,
        'password': password,
        'firstName': firstName,
        'lastName': lastName,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Signup failed');
    }
  }

  // Books endpoints
  Future<List<Book>> getBooks() async {
    final response = await http.get(
      Uri.parse('$baseUrl/books'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load books');
    }
  }

  Future<Book> getBook(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/$id'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      return Book.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load book');
    }
  }

  Future<List<Book>> searchBooks(String query) async {
    final response = await http.get(
      Uri.parse('$baseUrl/books/search/$query'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Book.fromJson(json)).toList();
    } else {
      throw Exception('Failed to search books');
    }
  }

  // Authors endpoints
  Future<List<Author>> getAuthors({String? query}) async {
    String url = '$baseUrl/authors';
    if (query != null && query.isNotEmpty) {
      url += '?q=$query';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Author.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load authors');
    }
  }

  Future<Map<String, dynamic>> getAuthorWithBooks(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/authors/$id/books'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'author': Author.fromJson(data['author']),
        'books': (data['books'] as List).map((json) => Book.fromJson(json)).toList(),
      };
    } else {
      throw Exception('Failed to load author with books');
    }
  }

  // Publishers endpoints
  Future<List<Publisher>> getPublishers({String? query}) async {
    String url = '$baseUrl/publishers';
    if (query != null && query.isNotEmpty) {
      url += '?q=$query';
    }

    final response = await http.get(
      Uri.parse(url),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Publisher.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load publishers');
    }
  }

  Future<Map<String, dynamic>> getPublisherWithBooks(String id) async {
    final response = await http.get(
      Uri.parse('$baseUrl/publishers/$id/books'),
      headers: _getHeaders(),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return {
        'publisher': Publisher.fromJson(data['publisher']),
        'books': (data['books'] as List).map((json) => Book.fromJson(json)).toList(),
      };
    } else {
      throw Exception('Failed to load publisher with books');
    }
  }

  // Admin endpoints
  Future<void> addBook(String title, String type, double price, String publisherId, String authorId, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/books'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'title': title,
        'type': type,
        'price': price,
        'publisherId': publisherId,
        'authorId': authorId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add book');
    }
  }

  Future<void> addAuthor(Author author, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/authors'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'firstName': author.firstName,
        'lastName': author.lastName,
        'country': author.country,
        'city': author.city,
        'address': author.address,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add author');
    }
  }

  Future<void> addPublisher(String name, String city, String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/publishers'),
      headers: _getHeaders(token: token),
      body: jsonEncode({
        'name': name,
        'city': city,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to add publisher');
    }
  }
}
