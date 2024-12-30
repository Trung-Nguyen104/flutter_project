import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'note_object.dart';
import 'create_or_edit.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<MyHomePage> createState() => MyHomePageStateView();
}

class AnimationLimiterController {
  VoidCallback? _resetAnimation;

  void reset() {
    if (_resetAnimation != null) {
      _resetAnimation!();
    }
  }

  void setResetCallback(VoidCallback resetCallback) {
    _resetAnimation = resetCallback;
  }
}

class MyHomePageStateView extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  late List<Note> _noteList;
  late List<Note> _filteredNoteList;
  bool isGrid = false;
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  final List<String> _selectedTags = [];
  List<String> _allTags = [];
  late AnimationController _controller;
  late Animation<double> _animation;
  Key _gridKey = UniqueKey();
  Key _listKey = UniqueKey();

  void _saveNote(Note note) async {
    setState(() {
      _noteList.add(note);
      _updateAllTags(note.tags);
    });
  }

  void _updateAllTags(List<String> newTags) {
    setState(() {
      for (var tag in newTags) {
        if (!_allTags.contains(tag)) {
          _allTags.add(tag);
        }
      }
    });
  }

  void _updateNoteAt(int index, Note updatedNote) async {
    setState(() {
      _noteList[index] = updatedNote;
      _updateAllTags(updatedNote.tags);
      _filterNotes();
    });
  }

  void _deleteNoteAt(int index) {
    setState(() {
      _noteList.removeAt(index);
    });
  }

  void _initAllTags() {
    _allTags = [];
    for (var note in _noteList) {
      _updateAllTags(note.tags);
    }
  }

  @override
  void initState() {
    super.initState();
    _initObjectList();
    _initAllTags();
    _filteredNoteList = _noteList;
    _searchController.addListener(_filterNotes);

    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterNotes() {
    setState(() {
      _filteredNoteList = _noteList.where((note) {
        bool matchesSearch = note.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()) ||
            note.content
                .toLowerCase()
                .contains(_searchController.text.toLowerCase());
        bool matchesTags = _selectedTags.isEmpty ||
            _selectedTags.any((tag) => note.tags.contains(tag));
        return matchesSearch && matchesTags;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 252, 255, 193),
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(
          'Notes App',
          style: GoogleFonts.poppins(
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 30,
              fontWeight: FontWeight.w600,
            ),
          ),
          textAlign: TextAlign.center,
        ),
        iconTheme: const IconThemeData(color: Colors.black, size: 30),
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search, size: 35),
            alignment: Alignment.center,
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                  _selectedTags.clear();
                  _filterNotes();
                }
              });
            },
          ),
          const Padding(padding: EdgeInsets.only(right: 8))
        ],
      ),
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return Opacity(
            opacity: _animation.value,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      height: _isSearching ? 70.0 : 0.0,
                      child: _isSearching
                          ? Row(
                              children: [
                                PopupMenuButton<String>(
                                  color: Colors.white,
                                  icon: const Icon(
                                    Icons.filter_alt,
                                    size: 30,
                                    color: Color.fromARGB(255, 112, 112, 112),
                                  ),
                                  onSelected: (String tag) {
                                    setState(() {
                                      if (_selectedTags.contains(tag)) {
                                        _selectedTags.remove(tag);
                                      } else {
                                        _selectedTags.add(tag);
                                      }
                                      _filterNotes();
                                    });
                                  },
                                  itemBuilder: (BuildContext context) {
                                    return _allTags.map((String tag) {
                                      return CheckedPopupMenuItem<String>(
                                        value: tag,
                                        checked: _selectedTags.contains(tag),
                                        child: Text(tag),
                                      );
                                    }).toList();
                                  },
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: _searchController,
                                    decoration: InputDecoration(
                                      hintText: 'Search notes...',
                                      prefixIcon: const Icon(
                                        Icons.search,
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                        borderSide: BorderSide.none,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                    if (_isSearching && _selectedTags.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _selectedTags
                              .map((tag) => Chip(
                                    side: BorderSide.none,
                                    backgroundColor: Colors.white,
                                    label: Padding(
                                      padding: const EdgeInsets.all(0),
                                      child: Text(tag),
                                    ),
                                    onDeleted: () {
                                      setState(() {
                                        _selectedTags.remove(tag);
                                        _filterNotes();
                                      });
                                    },
                                    labelPadding: const EdgeInsets.symmetric(
                                        horizontal: 2),
                                  ))
                              .toList(),
                        ),
                      ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height - 150,
                      child: isGrid
                          ? _buildAnimatedGridView()
                          : _buildAnimatedListView(),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
      floatingActionButton: ScaleTransition(
        scale: _animation,
        child: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 0, 206, 196),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(100)),
          onPressed: () {
            Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) =>
                    CreateOrEditNote(
                  onDone: (note) => _saveNote(note),
                ),
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  var begin = const Offset(1.0, 0.0);
                  var end = Offset.zero;
                  var curve = Curves.ease;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                    position: animation.drive(tween),
                    child: child,
                  );
                },
              ),
            );
          },
          child: const Icon(Icons.add),
        ),
      ),
      drawer: _buildDrawer(context),
    );
  }

  Widget _buildAnimatedGridView() {
    return AnimationLimiter(
      key: _gridKey,
      child: MasonryGridView.count(
        crossAxisCount: 2,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        itemCount: _filteredNoteList.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredGrid(
            position: index,
            duration: const Duration(milliseconds: 500),
            columnCount: 2,
            child: ScaleAnimation(
              child: FadeInAnimation(
                child: NoteWidget(
                  note: _filteredNoteList[index],
                  isGrid: true,
                  onDelete: () => _deleteNoteAt(index),
                  onEdit: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateOrEditNote(
                          onDone: (updatedNote) =>
                              _updateNoteAt(index, updatedNote),
                          note: _filteredNoteList[index],
                        ),
                      ),
                    );
                  },
                  onPin: () {
                    _sortNotes(index);
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedListView() {
    return AnimationLimiter(
      key: _listKey,
      child: ListView.builder(
        key: const ValueKey("ListView"),
        itemCount: _filteredNoteList.length,
        itemBuilder: (context, index) {
          return AnimationConfiguration.staggeredList(
            position: index,
            duration: const Duration(milliseconds: 500),
            child: SlideAnimation(
              verticalOffset: 50.0,
              child: FadeInAnimation(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NoteWidget(
                    note: _filteredNoteList[index],
                    isGrid: false,
                    onDelete: () => _deleteNoteAt(index),
                    onEdit: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateOrEditNote(
                            onDone: (updatedNote) =>
                                _updateNoteAt(index, updatedNote),
                            note: _filteredNoteList[index],
                          ),
                        ),
                      );
                    },
                    onPin: () {
                      _sortNotes(index);
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Column(
        children: [
          Container(
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Color.fromARGB(255, 0, 189, 157),
                ),
              ],
            ),
            height: MediaQuery.of(context).size.height / 7,
            padding: const EdgeInsets.only(left: 20),
            alignment: Alignment.centerLeft,
            child: const Text(
              'Setting',
              style: TextStyle(
                color: Colors.black,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: Icon(
                    isGrid ? Icons.list : Icons.grid_view,
                    color: Colors.black,
                  ),
                  title: const Text('Switch View'),
                  onTap: () {
                    setState(() {
                      isGrid = !isGrid;
                      _gridKey = UniqueKey();
                      _listKey = UniqueKey();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.settings, color: Colors.black),
                  title: const Text('version 1.0'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sortNotes(int index) {
    setState(() {
      Note note = _noteList[index];
      note.isPin = !note.isPin;

      if (note.isPin) {
        _noteList.removeAt(index);
        _noteList.insert(0, note);
      } else {
        int lastPinnedIndex = _noteList.lastIndexWhere((note) => note.isPin);
        _noteList.removeAt(index);
        _noteList.insert(lastPinnedIndex + 1, note);
      }

      _filterNotes();
    });
  }

  void _initObjectList() {
    _noteList = [
      Note(
          title: "Sample Note",
          content:
              "This is the content of the note. It can be a bit longer to test ellipsis.",
          tags: ["Work", "Personal", "Important"],
          createDate: DateTime.parse("2024-02-05"),
          checkboxList: []),
      Note(
          title: "Sample Note",
          content: "This is short Note.",
          tags: ["Work", "Personal", "Important"],
          createDate: DateTime.parse("2024-12-09"),
          checkboxList: []),
      Note(
        title: "Example Note with Image",
        content: "This is an example note with an image from assets.",
        tags: ["example", "image"],
        createDate: DateTime.parse("2024-27-12"),
        checkboxList: [],
      )
    ];
  }
}
