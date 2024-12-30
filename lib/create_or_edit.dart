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
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController tagController;
  late List<String> tags;
  late List<Map<String, dynamic>> checkboxList;
  final ImagePicker _picker = ImagePicker();
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
            child: GestureDetector(
              onTap: () {
                _saveNote();
              },
              child: const Text(
                "Done",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          )
        ],
      ),
      body: SingleChildScrollView(
          child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
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
            TextFormField(
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
      return Image.memory(
        _imageBytes!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox.shrink();
  }
}
