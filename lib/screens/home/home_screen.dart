import 'package:book_management_app/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth/login_screen.dart';
import '../books/books_screen.dart';
import '../authors/authors_screen.dart';
import '../publishers/publishers_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Management'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              final authService = Provider.of<AuthService>(context, listen: false);
              await authService.logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manage your book collection with ease',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Latest News Section
            Text(
              'Latest News',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.announcement, color: Colors.orange),
                      SizedBox(width: 8),
                      Text(
                        'System Update',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade800,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'New features added: Enhanced search functionality and improved user interface.',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            
            SizedBox(height: 30),
            
            // Quick Actions
            Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 15),
            
            GridView.count(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildActionCard(
                  context,
                  'Books',
                  Icons.book,
                  Colors.blue,
                  'Browse and manage books',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BooksScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Authors',
                  Icons.person,
                  Colors.green,
                  'Explore authors',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AuthorsScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Publishers',
                  Icons.business,
                  Colors.purple,
                  'View publishers',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => PublishersScreen()),
                  ),
                ),
                _buildActionCard(
                  context,
                  'Search',
                  Icons.search,
                  Colors.orange,
                  'Find anything',
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => BooksScreen(showSearch: true)),
                  ),
                ),
              ],
            ),
            
            SizedBox(height: 30),
            
            // Server Links Section
            Text(
              'Server Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 15),
            
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildServerLink('API Health Check', '/api/health'),
                  Divider(),
                  _buildServerLink('Books Endpoint', '/api/books'),
                  Divider(),
                  _buildServerLink('Authors Endpoint', '/api/authors'),
                  Divider(),
                  _buildServerLink('Publishers Endpoint', '/api/publishers'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    String subtitle,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 30,
                color: color,
              ),
            ),
            SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            SizedBox(height: 5),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServerLink(String title, String endpoint) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          Icon(Icons.link, size: 16, color: Colors.blue),
          SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  'localhost:34723$endpoint',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
