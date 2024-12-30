import 'package:flutter/material.dart';
import 'dart:typed_data';

class Note {
  String title;
  String content;
  List<String> tags;
  List<Map<String, dynamic>> checkboxList;
  Uint8List? imageBytes;
  Color color;
  bool isPin;
  DateTime createDate;

  Note({
    required this.title,
    required this.content,
    required this.tags,
    required this.checkboxList,
    required this.createDate,
    this.imageBytes,
    this.color = Colors.white,
    this.isPin = false,
  });
}

class NoteWidget extends StatelessWidget {
  final Note note;
  final bool isGrid;
  final VoidCallback onDelete;
  final VoidCallback onEdit;
  final VoidCallback onPin;

  const NoteWidget({
    required this.note,
    required this.isGrid,
    required this.onDelete,
    required this.onEdit,
    required this.onPin,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onEdit,
      onLongPress: () => _showNoteMenu(context),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: note.color,
          ),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (note.title.isNotEmpty) ...[
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
              ],
              if (note.content.isNotEmpty) ...[
                Text(
                  note.content,
                  style: const TextStyle(fontSize: 16),
                  maxLines: isGrid ? note.content.length : 1,
                  overflow: isGrid ? TextOverflow.clip : TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8)
              ],
              isGrid ? _buildImageGridWidget() : _showImageOnList(),
              if (note.checkboxList.isNotEmpty) ...[
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: note.checkboxList.map((checkbox) {
                    return Row(
                      children: [
                        Checkbox(
                          value: checkbox['checked'],
                          onChanged: null,
                        ),
                        Expanded(
                          child: Text(
                            checkbox['text'],
                            style: const TextStyle(color: Colors.black),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
                const SizedBox(height: 8),
              ],
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: note.tags
                    .map((tag) => Chip(
                          label: Text(tag),
                          labelStyle: const TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                          ),
                          backgroundColor:
                              const Color.fromARGB(255, 255, 232, 147),
                          padding: const EdgeInsets.all(0),
                          side: BorderSide.none,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(100),
                          ),
                        ))
                    .toList(),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Created: ${_formatDate(note.createDate)}',
                      style:
                          const TextStyle(fontSize: 12.3, color: Colors.grey),
                    ),
                    if (note.isPin)
                      Container(
                        alignment: Alignment.topRight,
                        child: Icon(
                          Icons.push_pin,
                          size: 20,
                          color: Colors.black.withOpacity(0.6),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageGridWidget() {
    if (note.imageBytes != null) {
      return Image.memory(
        note.imageBytes!,
        width: 200,
        height: 200,
        fit: BoxFit.contain,
      );
    }
    return const SizedBox.shrink();
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  Widget _showImageOnList() {
    if (note.imageBytes != null && note.imageBytes!.isNotEmpty) {
      return const Text(
        "(Image)",
        style: TextStyle(
            fontSize: 16, color: Colors.grey, fontStyle: FontStyle.italic),
        maxLines: 1,
      );
    }
    return const SizedBox.shrink();
  }

  void _showNoteMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          height: 150,
          child: Column(
            children: [
              Container(
                height: 6,
                width: 40,
                margin: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Remove Note'),
                onTap: () {
                  Navigator.pop(context);
                  onDelete();
                },
              ),
              ListTile(
                leading: Icon(
                    note.isPin ? Icons.push_pin : Icons.push_pin_outlined,
                    color: Colors.black),
                title: Text(note.isPin ? 'Unpin Note' : 'Pin Note'),
                onTap: () {
                  Navigator.pop(context);
                  onPin();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
