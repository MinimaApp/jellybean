import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const SearchBarApp());
}

class SearchBarApp extends StatelessWidget {
  const SearchBarApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.amber,
      ),
      home: const SearchBar(),
    );
  }
}

class SearchBar extends StatefulWidget {
  const SearchBar({Key? key}) : super(key: key);

  @override
  _SearchBarState createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  TextEditingController _controller = TextEditingController();
  List<dynamic>? _searchResults;

  Future<void> _search(String query) async {
    final response = await http.get(
      Uri.parse(
          'https://trackapi.nutritionix.com/v2/search/instant?query=$query'),
      headers: {
        'x-app-id': '58861aac',
        'x-app-key': '8f786a6efa99ae56cc6b23bb76221798',
      },
    );

    debugPrint(response.body); // Print the response body to the console.

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        // Update the _searchResults list with only the first 10 items from the "common" category
        _searchResults = data['common'].take(10).toList();
      });
    } else {
      setState(() {
        _searchResults = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Bar Demo'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      labelText: 'Search',
                      hintText: 'Enter search term',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[0],
                    ),
                  ),
                ),
                const SizedBox(width: 10.0),
                ElevatedButton(
                  onPressed: () {
                    _search(_controller.text);
                  },
                  child: const Text('SEARCH'),
                  style: ButtonStyle(
                    minimumSize: MaterialStateProperty.all(Size(50, 60)),
                    backgroundColor: MaterialStateProperty.all<Color>(
                        Theme.of(context).primaryColor),
                  ),
                ),
              ],
            ),
            if (_searchResults != null)
              Expanded(
                child: ListView.builder(
                  itemCount: _searchResults!.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      title: Text(_searchResults![index]['food_name']),
                      subtitle: Text(
                          'Brand: ${_searchResults![index]['brand_name'] ?? "Unknown"}'),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
