import 'package:flutter/material.dart';
import 'package:track_eet/database/database_model.dart';
import 'dart:io';
import '../models/media_item.dart';
import 'add_edit_item_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<MediaItem> _allMediaItems = [];
  List<MediaItem> _filteredMediaItems = [];
  String _selectedType = 'All';
  String _selectedSort = 'Alphabetically';
  final List<String> _mediaTypes = [
    'All',
    'Books',
    'Movies',
    'Series',
    'Games'
  ];
  final List<String> _sortOptions = ['Alphabetically', 'Rating', 'Duration'];

  @override
  void initState() {
    super.initState();
    _loadMediaItems();
  }

  Future<void> _loadMediaItems() async {
    try {
      final items = await DatabaseHelper.instance.readAllMediaItems();
      setState(() {
        _allMediaItems = items;
        _filterAndSortItems();
      });
    } catch (e) {
      print('Error loading media items: $e');
      setState(() {
        _allMediaItems = [];
        _filteredMediaItems = [];
      });
    }
  }

  void _filterItems(String type) {
    setState(() {
      _selectedType = type;
      _filterAndSortItems();
    });
  }

  void _sortItems(String sort) {
    setState(() {
      _selectedSort = sort;
      _filterAndSortItems();
    });
  }

int calculateDurationInDays({required DateTime startedAt, DateTime? endedAt}) {
  endedAt ??= DateTime.now();
  return endedAt.difference(startedAt).inDays;
}

  void _filterAndSortItems() {
    List<MediaItem> filtered = _selectedType == 'All'
        ? _allMediaItems
        : _allMediaItems.where((item) => item.type == _selectedType).toList();

    if (_selectedSort == 'Alphabetically') {
      filtered
          .sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else if (_selectedSort == 'Rating') {
      filtered.sort((a, b) => a.rating.compareTo(b.rating)); 
    }
    else if(_selectedSort == 'Duration'){
      filtered.sort((a,b) => calculateDurationInDays(startedAt: a.startedAt, endedAt: a.endedAt).compareTo(calculateDurationInDays(startedAt: b.startedAt, endedAt: b.endedAt)));
    }

    setState(() {
      _filteredMediaItems = filtered;
    });
  }

  void _editMediaItem(MediaItem item) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditItemScreen(mediaItem: item),
      ),
    );

    if (result != null) {
      await _loadMediaItems();
    }
  }

  void _deleteMediaItem(int id) async {
    try {
      await DatabaseHelper.instance.delete(id);
      _loadMediaItems(); 
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Item deleted successfully')),
      );
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete item')),
      );
    }
  }

  void _confirmDelete(int? id) {
    if (id == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this item?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _deleteMediaItem(id);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showSortMenu(BuildContext context) async {
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    final String? result = await showMenu<String>(
      context: context,
      position: position,
      items: _sortOptions.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              Text(option),
              const SizedBox(width: 8),
              if (_selectedSort == option)
                const Icon(Icons.check, color: Colors.indigoAccent),
            ],
          ),
        );
      }).toList(),
    );

    if (result != null) {
      _sortItems(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TrackEET'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                // Type filter dropdown
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      dropdownColor: Colors.indigo.shade100,
                      underline: const SizedBox(),
                      icon: const Icon(Icons.arrow_drop_down, color: Colors.indigo),
                      items: _mediaTypes.map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              type,
                              style: const TextStyle(fontWeight: FontWeight.w500),
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? type) {
                        if (type != null) {
                          _filterItems(type);
                        }
                      },
                    ),
                  ),
                ),
                
                // Sort button
                Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: IconButton(
                      tooltip: 'Sort by $_selectedSort',
                      icon: const Icon(Icons.sort, color: Colors.indigo),
                      onPressed: () => _showSortMenu(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredMediaItems.isEmpty
                ? const Center(
                    child: Text(
                      'No items found',
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMediaItems.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final item = _filteredMediaItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                        child: ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: item.imagePath != null
                                ? Image.file(File(item.imagePath!),
                                    width: 50, height: 50, fit: BoxFit.cover)
                                : const Icon(Icons.image,
                                    size: 50, color: Colors.indigoAccent),
                          ),
                          title: Text(
                            item.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo,
                            ),
                          ),
                          subtitle: Text(
                            '${item.type} | Rating: ${item.rating}/5',
                            style: const TextStyle(color: Colors.black87),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit,
                                    color: Colors.indigoAccent),
                                onPressed: () => _editMediaItem(item),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete,
                                    color: Colors.redAccent),
                                onPressed: () => _confirmDelete(item.id),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.indigoAccent,
        child: const Icon(Icons.add),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
        ).then((_) => _loadMediaItems()),
      ),
    );
  }
}