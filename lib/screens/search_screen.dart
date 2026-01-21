import 'package:flutter/material.dart';
import 'package:nyc_parks/providers/logged_in_user_provider.dart';
import 'package:nyc_parks/providers/park_provider.dart';
import 'package:nyc_parks/screens/park_screen.dart';
import 'package:nyc_parks/screens/user_screen.dart';
import 'package:nyc_parks/services/search_services.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final SearchService searchService = SearchService();
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> searchResults = [];
  bool isLoading = false;
  bool hasSearched = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> performSearch() async {
    final query = searchController.text.trim();
    
    if (query.isEmpty) {
      setState(() {
        searchResults = [];
        hasSearched = false;
      });
      return;
    }

    setState(() {
      isLoading = true;
      hasSearched = true;
    });

    final loggedInUserId = Provider.of<LoggedInUserProvider>(context, listen: false).user.id;
    final results = await searchService.search(
      query: query,
      loggedInUserId: loggedInUserId,
    );

    setState(() {
      searchResults = results;
      isLoading = false;
    });
  }

  void navigateToPark(String globalId) {
    Provider.of<ParksProvider>(context, listen: false).setActiveParkFromGlobalId(globalId);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkScreen(),
      ),
    );
  }

  void navigateToUser(int userId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserScreen(userId: userId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Parks'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Search parks, locations, reviews...',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: const Icon(Icons.search),
                suffixIcon: searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          setState(() {
                            searchResults = [];
                            hasSearched = false;
                          });
                        },
                      )
                    : null,
              ),
              onChanged: (value) {
                setState(() {}); // Rebuild to show/hide clear button
              },
              onSubmitted: (value) => performSearch(),
            ),
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : hasSearched && searchResults.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey),
                      SizedBox(height: 16),
                      Text(
                        'No results found',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : !hasSearched
                  ? const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search, size: 64, color: Colors.grey),
                          SizedBox(height: 16),
                          Text(
                            'Search for parks, locations, or reviews',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final result = searchResults[index];
                        final points = result['points']?.toDouble() ?? 0.0;
                        
                        // Check if it's a standalone review
                        final isReview = result['type'] == 'review';

                        if (isReview) {
                          // Display standalone review
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: const Icon(Icons.rate_review),
                              title: Text(
                                result['comments'] ?? 'No comment',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Park ID: ${result['parkId']}'),
                                  Text(
                                    'Rating: ${result['stars']}⭐',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${points.toStringAsFixed(1)} pts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              onTap: () => navigateToPark(result['parkId']),
                            ),
                          );
                        } else {
                          // Display park result
                          final matchingReviews = result['matchingReviews'] as List? ?? [];
                          
                          return Card(
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ExpansionTile(
                              leading: const Icon(Icons.park),
                              title: Text(
                                result['SIGNNAME'] ?? result['NAME311'] ?? 'Unknown Park',
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (result['LOCATION'] != null)
                                    Text(result['LOCATION']),
                                  Row(
                                    children: [
                                      if (result['BOROUGH'] != null)
                                        Text(
                                          result['BOROUGH'],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      if (result['ZIPCODE'] != null)
                                        Text(
                                          ' • ${result['ZIPCODE']}',
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Text(
                                '${points.toStringAsFixed(1)} pts',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                              children: [
                                if (matchingReviews.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Matching Reviews:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        ...matchingReviews.map((review) => Padding(
                                              padding: const EdgeInsets.only(bottom: 8.0),
                                              child: Row(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Icon(Icons.comment, size: 16),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Text(
                                                          review['comments'] ?? 'No comment',
                                                          style: const TextStyle(fontSize: 13),
                                                        ),
                                                        Text(
                                                          '${review['stars']}⭐',
                                                          style: const TextStyle(
                                                            fontSize: 12,
                                                            color: Colors.grey,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )),
                                      ],
                                    ),
                                  ),
                                ListTile(
                                  title: const Text('View Park Details'),
                                  trailing: const Icon(Icons.arrow_forward),
                                  onTap: () => navigateToPark(result['GlobalID']),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                    ),
    );
  }
}

