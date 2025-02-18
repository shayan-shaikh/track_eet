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
      _type = 'Book';
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
          endedAt: _endedAt);

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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.mediaItem == null ? 'Add Item' : 'Edit Item'),
        centerTitle: true,
        backgroundColor: Colors.indigoAccent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      height: 200,
                      decoration: BoxDecoration(
                        color: Colors.indigo.shade50,
                        borderRadius: BorderRadius.circular(12.0),
                        border: Border.all(color: Colors.indigoAccent),
                      ),
                      child: _imagePath != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12.0),
                              child: Image.file(
                                File(_imagePath!),
                                fit: BoxFit.cover,
                                width: double.infinity,
                              ),
                            )
                          : const Center(
                              child: Text(
                                'Tap to add image',
                                style: TextStyle(
                                  color: Colors.indigo,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _name,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      labelStyle: const TextStyle(color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    validator: (value) =>
                        value!.isEmpty ? 'Please enter a name' : null,
                    onSaved: (value) => _name = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _description,
                    decoration: InputDecoration(
                      labelText: 'Description',
                      labelStyle: const TextStyle(color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    maxLines: 3,
                    onSaved: (value) => _description = value!,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    initialValue: _author,
                    decoration: InputDecoration(
                      labelText: 'Author/Creator',
                      labelStyle: const TextStyle(color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    onSaved: (value) => _author = value!,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _mediaTypes.contains(_type) ? _type : null,
                    decoration: InputDecoration(
                      labelText: 'Type',
                      labelStyle: const TextStyle(color: Colors.indigo),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
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
                  const SizedBox(height: 16),
                  Text(
                    'Rating: $_rating/5',
                    style: const TextStyle(
                        color: Colors.indigo, fontWeight: FontWeight.w500),
                  ),
                  Slider(
                    value: _rating,
                    min: 0,
                    max: 5,
                    divisions: 10,
                    label: _rating.toString(),
                    activeColor: Colors.indigoAccent,
                    onChanged: (value) => setState(() {
                      _rating = value;
                    }),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Start Date: ${_startAt.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _pickStartDate,
                    child: const Text('Select Start Date'),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'End Date: ${_endedAt?.toLocal().toString().split(' ')[0] ?? 'Not selected'}',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton(
                    onPressed: _pickEndDate,
                    child: const Text('Select End Date'),
                  ),
                  const SizedBox(height: 16),
                  Text('Duration : ${calculateDurationInDays(startedAt: _startAt, endedAt: _endedAt)} days',
                  style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _saveMediaItem,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.indigoAccent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                    ),
                    child: const Center(
                      child: Text('Save'),
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
}
