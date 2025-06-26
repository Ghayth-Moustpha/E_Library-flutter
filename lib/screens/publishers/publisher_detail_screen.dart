import 'package:book_management_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import '../books/book_detail_screen.dart';

class PublisherDetailScreen extends StatefulWidget {
  final Publisher publisher;

  const PublisherDetailScreen({super.key, required this.publisher});

  @override
  _PublisherDetailScreenState createState() => _PublisherDetailScreenState();
}

class _PublisherDetailScreenState extends State<PublisherDetailScreen> {
  List<Book> books = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPublisherBooks();
  }

  Future<void> _loadPublisherBooks() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final result = await apiService.getPublisherWithBooks(widget.publisher.id);
      setState(() {
        books = result['books'];
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load publisher books: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Publisher Details'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Publisher Avatar
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.purple.shade100,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.business,
                  size: 60,
                  color: Colors.purple,
                ),
              ),
            ),
            
            SizedBox(height: 20),
            
            // Publisher Name
            Center(
              child: Text(
                widget.publisher.name,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Publisher Details
            Text(
              'Publisher Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 10),
            _buildDetailCard([
              _buildDetailRow('Name', widget.publisher.name),
              _buildDetailRow('City', widget.publisher.city),
            ]),
            
            SizedBox(height: 30),
            
            // Books Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Books by this Publisher',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                if (!isLoading)
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${books.length} books',
                      style: TextStyle(
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 15),
            
            if (isLoading)
              Center(child: CircularProgressIndicator())
            else if (books.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(40),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.book_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No books found for this publisher',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: books.map((book) => Card(
                  margin: EdgeInsets.only(bottom: 12),
                  elevation: 2,
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: Container(
                      width: 40,
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(
                        Icons.book,
                        color: Colors.blue,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      book.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        if (book.author != null)
                          Text(
                            'By ${book.author!.fullName}',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
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
                )).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey.shade800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
