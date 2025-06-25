import 'package:flutter/material.dart';
import '../../models/book.dart';

class BookDetailScreen extends StatelessWidget {
  final Book book;

  const BookDetailScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Book Cover Placeholder
            Center(
              child: Container(
                width: 150,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
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
                  Icons.book,
                  size: 80,
                  color: Colors.blue,
                ),
              ),
            ),
            
            SizedBox(height: 30),
            
            // Book Title
            Text(
              book.title,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            
            SizedBox(height: 20),
            
            // Book Details
            _buildDetailCard([
              _buildDetailRow('Type', book.type),
              _buildDetailRow('Price', '\$${book.price.toStringAsFixed(2)}'),
            ]),
            
            SizedBox(height: 20),
            
            // Author Information
            if (book.author != null) ...[
              Text(
                'Author Information',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(height: 10),
              _buildDetailCard([
                _buildDetailRow('Name', book.author!.fullName),
                _buildDetailRow('Country', book.author!.country),
                _buildDetailRow('City', book.author!.city),
                if (book.author!.address.isNotEmpty)
                  _buildDetailRow('Address', book.author!.address),
              ]),
              SizedBox(height: 20),
            ],
            
            // Publisher Information
            if (book.publisher != null) ...[
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
                _buildDetailRow('Name', book.publisher!.name),
                _buildDetailRow('City', book.publisher!.city),
              ]),
            ],
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
