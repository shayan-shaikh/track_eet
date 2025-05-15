import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:track_eet/database/database_model.dart';
import 'dart:io';

import 'package:track_eet/models/media_item.dart';

class AddEditItemScreen extends StatefulWidget {
  final MediaItem? mediaItem;

  const AddEditItemScreen({super.key, this.mediaItem});

  @override
  _AddEditItemScreenState createState() => _AddEditItemScreenState();
}

class _AddEditItemScreenState extends State<AddEditItemScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _description;
  late String _author;
  late double _rating;
  late String _type;
  late DateTime _startAt;
  String? _imagePath;
  DateTime? _endedAt;

  final List<String> _mediaTypes = ['Books', 'Movies', 'Series', 'Games'];

  @override
  void initState() {
    super.initState();
    if (widget.mediaItem != null) {
      _name = widget.mediaItem!.name;
      _description = widget.mediaItem!.description;
      _author = widget.mediaItem!.author;
      _rating = widget.mediaItem!.rating;
      _type = widget.mediaItem!.type;
      _imagePath = widget.mediaItem!.imagePath;
      _startAt = widget.mediaItem!.startedAt;
      _endedAt = widget.mediaItem!.endedAt;
    } else {
      _name = '';
      _description = '';
      _author = '';
      _rating = 0.0;
      _type = 'Books';
      _startAt = DateTime.now();
    }
  }

  int calculateDurationInDays({required DateTime startedAt, DateTime? endedAt}) {
    endedAt ??= DateTime.now();
    return endedAt.difference(startedAt).inDays;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  Future<void> _pickStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startAt,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _startAt) {
      setState(() {
        _startAt = picked;
      });
    }
  }

  Future<void> _pickEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endedAt ?? _startAt,
      firstDate: _startAt,
      lastDate: DateTime(2100),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: Theme.of(context).colorScheme.primary,
              onPrimary: Colors.black,
            ),
            dialogBackgroundColor: Theme.of(context).colorScheme.surface,
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _endedAt = picked;
      });
    }
  }

  void _saveMediaItem() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final mediaItem = MediaItem(
        id: widget.mediaItem?.id,
        name: _name,
        description: _description,
        author: _author,
        rating: _rating,
        type: _type,
        imagePath: _imagePath,
        startedAt: _startAt,
        endedAt: _endedAt
      );

      if (widget.mediaItem == null) {
        await DatabaseHelper.instance.create(mediaItem);
      } else {
        await DatabaseHelper.instance.update(mediaItem);
      }

      Navigator.pop(context, mediaItem);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;
    final secondaryColor = Theme.of(context).colorScheme.secondary;
    final backgroundColor = Theme.of(context).colorScheme.background;
    final surfaceColor = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: Text(
          widget.mediaItem == null ? 'ADD ITEM' : 'EDIT ITEM',
          style: const TextStyle(
            letterSpacing: 3.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
            side: BorderSide(color: primaryColor, width: 1.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image Picker
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: surfaceColor,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: secondaryColor, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: secondaryColor.withOpacity(0.2),
                            blurRadius: 10,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: _imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(10.5),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : SizedBox.expand(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_outlined,
          color: primaryColor,
          size: 50,
        ),
        const SizedBox(height: 8),
        Text(
          'TAP TO ADD IMAGE',
          style: TextStyle(
            color: primaryColor,
            fontWeight: FontWeight.w500,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ),
)

                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  _buildSectionHeader('NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _name,
                    style: TextStyle(
                      color: primaryColor,
                      letterSpacing: 0.8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter name',
                      hintStyle: TextStyle(
                        color: primaryColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 20),
                  
                  // Description Field
                  _buildSectionHeader('DESCRIPTION'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _description,
                    style: TextStyle(
                      color: primaryColor,
                      letterSpacing: 0.8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter description',
                      hintStyle: TextStyle(
                        color: primaryColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _description = value!,
                  ),
                  const SizedBox(height: 20),
                  
                  // Author Field
                  _buildSectionHeader('AUTHOR/CREATOR'),
                  const SizedBox(height: 8),
                  TextFormField(
                    initialValue: _author,
                    style: TextStyle(
                      color: primaryColor,
                      letterSpacing: 0.8,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Enter author/creator',
                      hintStyle: TextStyle(
                        color: primaryColor.withOpacity(0.5),
                        letterSpacing: 0.5,
                      ),
                    ),
                    onSaved: (value) => _author = value!,
                  ),
                  const SizedBox(height: 20),
                  
                  // Media Type Dropdown
                  _buildSectionHeader('TYPE'),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      border: Border.all(color: primaryColor, width: 1.0),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: _mediaTypes.contains(_type) ? _type : _mediaTypes.first,
                      dropdownColor: surfaceColor,
                      style: TextStyle(
                        color: primaryColor,
                        letterSpacing: 0.8,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
                      ),
                      items: _mediaTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) => setState(() {
                        _type = value!;
                      }),
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // Rating Slider
                  _buildSectionHeader('RATING: ${_rating.toStringAsFixed(1)}/5'),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) => setState(() {
                      _rating = value;
                    }),
                  ),
                  const SizedBox(height: 20),
                  
                  // Date Selectors
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('START DATE'),
                            const SizedBox(height: 4),
                            Text(
                              '${_startAt.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickStartDate,
                              icon: Icon(Icons.calendar_today, size: 16),
                              label: Text('SELECT', style: TextStyle(letterSpacing: 1.0)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSectionHeader('END DATE'),
                            const SizedBox(height: 4),
                            Text(
                              '${_endedAt?.toLocal().toString().split(' ')[0] ?? 'NOT SET'}',
                              style: TextStyle(
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: _pickEndDate,
                              icon: Icon(Icons.calendar_today, size: 16),
                              label: Text('SELECT', style: TextStyle(letterSpacing: 1.0)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  
                  // Duration Display
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: secondaryColor, width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: secondaryColor.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.timelapse, color: secondaryColor),
                        const SizedBox(width: 8),
                        Text(
                          'DURATION: ${calculateDurationInDays(startedAt: _startAt, endedAt: _endedAt)} DAYS',
                          style: TextStyle(
                            color: secondaryColor, 
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Save Button
                  Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: _saveMediaItem,
                      child: Text(
                        'SAVE',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.secondary,
        letterSpacing: 1.5,
      ),
    );
  }
}