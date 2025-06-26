import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:book_management_app/api_service.dart';
import '../../models/book.dart';
import 'book_detail_screen.dart';

class BooksScreen extends StatefulWidget {
  final bool showSearch;

  const BooksScreen({super.key, this.showSearch = false});

  @override
  _BooksScreenState createState() => _BooksScreenState();
}

class _BooksScreenState extends State<BooksScreen> {
  List<Book> books = [];
  List<Book> filteredBooks = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _loadBooks();

    if (widget.showSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadBooks() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedBooks = await apiService.getBooks();
      setState(() {
        books = loadedBooks;
        filteredBooks = loadedBooks;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load books: ${e.toString()}')),
      );
    }
  }

  void _filterBooks(String query) {
    setState(() {
      searchQuery = query;
      if (query.isEmpty) {
        filteredBooks = books;
      } else {
        filteredBooks = books.where((book) =>
            book.title.toLowerCase().contains(query.toLowerCase()) ||
            (book.author?.fullName.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            (book.publisher?.name.toLowerCase().contains(query.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              decoration: InputDecoration(
                hintText: 'Search books, authors, publishers...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onChanged: _filterBooks,
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredBooks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.book_outlined, size: 64, color: Colors.grey),
                            SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty
                                  ? 'No books available'
                                  : 'No books found for "$searchQuery"',
                              style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadBooks,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredBooks.length,
                          itemBuilder: (context, index) {
                            final book = filteredBooks[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: Container(
                                  width: 50,
                                  height: 70,
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade100,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(Icons.book, color: Colors.blue, size: 30),
                                ),
                                title: Text(
                                  book.title,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    if (book.author != null)
                                      Text('By ${book.author!.fullName}',
                                          style: TextStyle(color: Colors.grey.shade600)),
                                    if (book.publisher != null)
                                      Text('Published by ${book.publisher!.name}',
                                          style: TextStyle(color: Colors.grey.shade600)),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: Colors.green.shade100,
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            book.type,
                                            style: TextStyle(
                                              color: Colors.green.shade700,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '\$${book.price.toStringAsFixed(2)}',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Colors.blue.shade700,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => BookDetailScreen(book: book),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
