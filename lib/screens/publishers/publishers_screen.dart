import 'package:book_management_app/api_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/book.dart';
import 'publisher_detail_screen.dart';

class PublishersScreen extends StatefulWidget {
  const PublishersScreen({super.key});

  @override
  _PublishersScreenState createState() => _PublishersScreenState();
}

class _PublishersScreenState extends State<PublishersScreen> {
  List<Publisher> publishers = [];
  List<Publisher> filteredPublishers = [];
  bool isLoading = true;
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPublishers();
  }

  Future<void> _loadPublishers() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final loadedPublishers = await apiService.getPublishers();
      setState(() {
        publishers = loadedPublishers;
        filteredPublishers = loadedPublishers;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load publishers: ${e.toString()}')),
      );
    }
  }

  Future<void> _searchPublishers(String query) async {
    if (query.isEmpty) {
      setState(() {
        filteredPublishers = publishers;
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
      final searchResults = await apiService.getPublishers(query: query);
      setState(() {
        filteredPublishers = searchResults;
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
        title: Text('Publishers'),
        backgroundColor: Colors.purple,
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
                hintText: 'Search publishers by name...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
              ),
              onSubmitted: _searchPublishers,
              onChanged: (value) {
                if (value.isEmpty) {
                  _searchPublishers('');
                }
              },
            ),
          ),
          
          // Publishers List
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredPublishers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.business_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              searchQuery.isEmpty 
                                  ? 'No publishers available'
                                  : 'No publishers found for "$searchQuery"',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadPublishers,
                        child: ListView.builder(
                          padding: EdgeInsets.all(16),
                          itemCount: filteredPublishers.length,
                          itemBuilder: (context, index) {
                            final publisher = filteredPublishers[index];
                            return Card(
                              margin: EdgeInsets.only(bottom: 12),
                              elevation: 2,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.purple.shade100,
                                  child: Icon(
                                    Icons.business,
                                    color: Colors.purple,
                                  ),
                                ),
                                title: Text(
                                  publisher.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 4),
                                    Text(
                                      publisher.city,
                                      style: TextStyle(color: Colors.grey.shade600),
                                    ),
                                  ],
                                ),
                                trailing: Icon(Icons.arrow_forward_ios),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PublisherDetailScreen(publisher: publisher),
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
