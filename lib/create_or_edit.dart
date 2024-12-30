import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'dart:typed_data';

import 'note_object.dart';

class CreateOrEditNote extends StatefulWidget {
  final Function(Note) onDone;
  final Note? note;

  const CreateOrEditNote({super.key, required this.onDone, this.note});

  @override
  State<CreateOrEditNote> createState() => _CreateNoteState();
}

class _CreateNoteState extends State<CreateOrEditNote> {
  static const double bottomMenuIconSize = 35;
  late FocusNode titleFocusNode;
  late FocusNode contentFocusNode;
  late FocusNode taskFocusNode;
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController tagController;
  late List<String> tags;
  late List<Map<String, dynamic>> checkboxList;
  final ImagePicker _picker = ImagePicker();
  bool _isEditing = false;
  Uint8List? _imageBytes;
  Color noteColor = Colors.white;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.note?.title ?? "");
    contentController = TextEditingController(text: widget.note?.content ?? "");
    tagController = TextEditingController();
    tags = widget.note?.tags ?? [];
    checkboxList = widget.note?.checkboxList ?? [];
    _imageBytes = widget.note?.imageBytes;

    titleFocusNode = FocusNode();
    contentFocusNode = FocusNode();
    taskFocusNode = FocusNode();
    titleFocusNode.addListener(_onFocusChange);
    contentFocusNode.addListener(_onFocusChange);
    taskFocusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    titleFocusNode.removeListener(_onFocusChange);
    contentFocusNode.removeListener(_onFocusChange);
    taskFocusNode.removeListener(_onFocusChange);
    titleFocusNode.dispose();
    contentFocusNode.dispose();
    taskFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isEditing = titleFocusNode.hasFocus ||
          contentFocusNode.hasFocus ||
          taskFocusNode.hasFocus;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 255, 193),
      appBar: AppBar(
        forceMaterialTransparency: true,
        iconTheme: const IconThemeData(
          color: Colors.black,
          size: 30,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20),
            child: TextButton(
              onPressed: () {
                if (_isEditing) {
                  FocusScope.of(context).unfocus();
                } else {
                  _saveNote();
                }
              },
              child: Text(
                _isEditing ? "Done" : "Save",
                style: const TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 23,
                ),
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              focusNode: titleFocusNode,
              controller: titleController,
              style: const TextStyle(fontSize: 28, color: Colors.black),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "New Title",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              focusNode: contentFocusNode,
              controller: contentController,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: "New Content",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
            _buildImageWidget(),
            ...checkboxList.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> checkbox = entry.value;
              return Row(
                children: [
                  Checkbox(
                    value: checkbox['checked'],
                    onChanged: (value) {
                      setState(() {
                        checkboxList[index]['checked'] = value;
                      });
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                      focusNode: taskFocusNode,
                      initialValue: checkbox['text'],
                      onChanged: (value) {
                        setState(() {
                          checkboxList[index]['text'] = value;
                        });
                      },
                      style: const TextStyle(color: Colors.black),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: "New task",
                        hintStyle: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.grey),
                    onPressed: () {
                      setState(() {
                        checkboxList.removeAt(index);
                      });
                    },
                  ),
                ],
              );
            }),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: tags
                  .map(
                    (tag) => Chip(
                      label: Text(tag),
                      labelStyle: const TextStyle(color: Colors.grey),
                      backgroundColor: const Color.fromARGB(255, 255, 232, 147),
                      deleteIconColor: Colors.grey,
                      padding: const EdgeInsets.all(0),
                      side: BorderSide.none,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      onDeleted: () {
                        setState(() {
                          tags.remove(tag);
                        });
                      },
                    ),
                  )
                  .toList(),
            ),
          ],
        ),
      )),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: noteColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 8, 0, 25),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.tag,
                  color: Colors.black87,
                  size: bottomMenuIconSize,
                ),
                onPressed: () {
                  _addTag(context);
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.check_box,
                  color: Colors.black87,
                  size: bottomMenuIconSize,
                ),
                onPressed: _addCheckListItem,
              ),
              IconButton(
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.black87,
                  size: bottomMenuIconSize,
                ),
                onPressed: _pickImage,
              ),
              IconButton(
                icon: const Icon(
                  Icons.palette,
                  color: Colors.black87,
                  size: bottomMenuIconSize,
                ),
                onPressed: _showColorPicker,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveNote() async {
    if (titleController.text.isNotEmpty ||
        contentController.text.isNotEmpty ||
        _imageBytes != null ||
        checkboxList.isNotEmpty) {
      final note = Note(
        content: contentController.text,
        title: titleController.text,
        tags: tags,
        checkboxList: checkboxList,
        imageBytes: _imageBytes,
        color: noteColor,
        createDate: widget.note?.createDate ?? DateTime.now(),
      );
      widget.onDone(note);
    }
    Navigator.pop(context);
  }

  void _addTag(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Tag"),
          titleTextStyle:
              const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: tagController,
                decoration: const InputDecoration(
                  labelText: "Tag Name",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (tagController.text.isNotEmpty) {
                    setState(() {
                      tags.add(tagController.text);
                      tagController.clear();
                    });
                  }
                  Navigator.pop(context);
                },
                child: const Text("Done"),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addCheckListItem() {
    setState(() {
      checkboxList.add({
        'checked': false,
        'text': '',
      });
    });
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = bytes;
      });
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: noteColor,
              onColorChanged: (Color color) {
                setState(() {
                  noteColor = color;
                });
              },
              pickerAreaHeightPercent: 0.8,
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Done'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildImageWidget() {
    if (_imageBytes != null) {
      return Stack(
        children: [
          Container(
            constraints: const BoxConstraints(
                maxHeight: 500, maxWidth: 500 // Giới hạn chiều cao tối đa
                ),
            child: Image.memory(
              _imageBytes!,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
            child: GestureDetector(
              onTap: _deleteImage,
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.black,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _deleteImage() {
    setState(() {
      _imageBytes = null;
    });
  }
}
