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
        SnackBar(
          content: Text('Item deleted successfully'),
          backgroundColor: Theme.of(context).colorScheme.surface,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
          ),
        ),
      );
    } catch (e) {
      print('Error deleting item: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete item'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _confirmDelete(int? id) {
    if (id == null) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
        ),
        title: Text(
          'CONFIRM DELETE',
          style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
            letterSpacing: 1.5,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this item?',
          style: TextStyle(letterSpacing: 0.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: Text(
              'CANCEL',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                letterSpacing: 1.2,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); 
              _deleteMediaItem(id);
            },
            child: Text(
              'DELETE',
              style: TextStyle(
                color: Theme.of(context).colorScheme.error,
                letterSpacing: 1.2,
              ),
            ),
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
      color: Theme.of(context).colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1),
      ),
      items: _sortOptions.map((String option) {
        return PopupMenuItem<String>(
          value: option,
          child: Row(
            children: [
              Text(
                option,
                style: TextStyle(
                  color: _selectedSort == option
                      ? Theme.of(context).colorScheme.secondary
                      : Theme.of(context).colorScheme.primary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(width: 8),
              if (_selectedSort == option)
                Icon(Icons.check, color: Theme.of(context).colorScheme.secondary),
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
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text(
          'TRACKEET',
          style: TextStyle(
            letterSpacing: 3.0,
            fontWeight: FontWeight.bold,
          ),
        ),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: primaryColor, width: 1.0),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedType,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).colorScheme.surface,
                      underline: const SizedBox(),
                      icon: Icon(Icons.arrow_drop_down, color: primaryColor),
                      items: _mediaTypes.map((String type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              type,
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: primaryColor,
                                letterSpacing: 1.0,
                              ),
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
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: primaryColor, width: 1.0),
                    ),
                    child: IconButton(
                      tooltip: 'Sort by $_selectedSort',
                      icon: Icon(Icons.sort, color: primaryColor),
                      onPressed: () => _showSortMenu(context),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredMediaItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 64,
                          color: primaryColor.withOpacity(0.5),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'NO ITEMS FOUND',
                          style: TextStyle(
                            fontSize: 18, 
                            color: primaryColor.withOpacity(0.7),
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredMediaItems.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      final item = _filteredMediaItems[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                          leading: Container(
                            width: 55,
                            height: 55,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.0),
                              border: Border.all(color: secondaryColor, width: 1.0),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7.0),
                              child: item.imagePath != null
                                  ? Image.file(File(item.imagePath!),
                                      width: 50, height: 50, fit: BoxFit.cover)
                                  : Icon(Icons.image,
                                      size: 30, color: primaryColor),
                            ),
                          ),
                          title: Text(
                            item.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                              letterSpacing: 1.2,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: secondaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: secondaryColor, width: 1),
                                    ),
                                    child: Text(
                                      item.type,
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: secondaryColor,
                                        letterSpacing: 0.8,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(Icons.star, size: 14, color: primaryColor),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${item.rating}/5',
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: primaryColor),
                                tooltip: 'EDIT',
                                onPressed: () => _editMediaItem(item),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Theme.of(context).colorScheme.error),
                                tooltip: 'DELETE',
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
        backgroundColor: secondaryColor,
        child: const Icon(Icons.add, color: Colors.black),
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddEditItemScreen()),
        ).then((_) => _loadMediaItems()),
      ),
    );
  }
}