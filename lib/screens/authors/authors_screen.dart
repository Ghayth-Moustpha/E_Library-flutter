import 'package:book_management_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import 'author_detail_screen.dart';

class AuthorsScreen extends StatefulWidget {
  @override
  _AuthorsScreenState createState() => _AuthorsScreenState();
}

class _AuthorsScreenState extends State<AuthorsScreen> {
  List<Author> authors = [];
  List<Author> filteredAuthors = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAuthors();
  }

  Future<void> _loadAuthors() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedAuthors = await apiService.getAuthors();
      setState(() {
        authors = loadedAuthors;
        filteredAuthors = loadedAuthors;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load authors: ${e.toString()}')),
      );
    }
  }

  Future<void> _searchAuthors(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredAuthors = authors;
        searchQuery = query;
      });
      return;
    }

    setState(() {
      isLoading = true;
      searchQuery = query;
    });

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final searchResults = await apiService.getAuthors(query: query);
      setState(() {
        filteredAuthors = searchResults;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Search failed: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authors'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            padding: EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search authors by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: _searchAuthors,
              onChanged: (value) {
                if (value.isEmpty) {
                  _searchAuthors('');
                }
              },
            ),
          ),
          
          // Authors List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredAuthors.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_outline,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty 
                                  ? 'No authors available'
                                  : 'No authors found for "$searchQuery"',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadAuthors,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredAuthors.length,
                          itemBuilder: (context, index) {
                            final author = filteredAuthors[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.green.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.green,
                                  ),
                                ),
                                title: Text(
                                  author.fullName,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    if (author.country.isNotEmpty)
                                      Text(
                                        '${author.city}, ${author.country}',
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                    if (author.address.isNotEmpty)
                                      Text(
                                        author.address,
                                        style: TextStyle(color: Colors.grey.shade600),
                                      ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AuthorDetailScreen(author: author),
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

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
