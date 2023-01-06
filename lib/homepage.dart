// ignore_for_file: unnecessary_null_comparison

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:helix_todo/searchbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // text fields' controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  final CollectionReference _tasks =
      FirebaseFirestore.instance.collection('tasks');

  // This function is triggered when the floating button or one of the edit buttons is pressed
  // Adding a product if no documentSnapshot is passed
  // If documentSnapshot != null then update an existing product
  Future<void> _createOrUpdate([DocumentSnapshot? documentSnapshot]) async {
    String action = 'create';
    if (documentSnapshot != null) {
      action = 'update';
      _nameController.text = documentSnapshot['name'];
      _descriptionController.text = documentSnapshot['description'].toString();
    }

    await showModalBottomSheet(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        isScrollControlled: true,
        context: context,
        builder: (BuildContext ctx) {
          double screenWidth = MediaQuery.of(context).size.width;
          double screenHeight = MediaQuery.of(context).size.height;
          return Container(
              padding: EdgeInsets.only(
                  top: 20,
                  left: 20,
                  right: 20,
                  // prevent the soft keyboard from covering text fields
                  bottom: MediaQuery.of(ctx).viewInsets.bottom + 20),
              child: Expanded(
                  child: Container(
                height: screenHeight / 1.2,
                width: screenWidth / 2,
                decoration: BoxDecoration(
                  border: Border.all(),
                  boxShadow: const [
                    BoxShadow(
                      blurStyle: BlurStyle.normal,
                      blurRadius: 5,
                      color: Color.fromARGB(200, 22, 22, 22),
                    )
                  ],
                  borderRadius: BorderRadius.circular(24),
                  color: const Color.fromARGB(55, 22, 22, 22),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                        // ignore: avoid_unnecessary_containers
                        child: Container(
                            child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _nameController,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                        hintText: 'Task Name',
                        hintStyle: TextStyle(
                          color: Color.fromARGB(100, 220, 220, 220),
                        ),
                      ),
                    ))),
                    Expanded(
                        flex: 10,
                        child: TextField(
                          maxLines: 90,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          controller: _descriptionController,
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                            border: InputBorder.none,
                            hintText: 'Task Description',
                            hintStyle: TextStyle(
                              color: Color.fromARGB(100, 220, 220, 220),
                            ),
                          ),
                        )),
                    Expanded(
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                          ElevatedButton(
                            clipBehavior: Clip.antiAlias,
                            child:
                                Text(action == 'create' ? 'Create' : 'Update'),
                            onPressed: () async {
                              final String name = _nameController.text;
                              final String description =
                                  _descriptionController.text;
                              if (name != null && description != null) {
                                if (action == 'create') {
                                  // Persist a new product to Firestore
                                  await _tasks.add({
                                    "name": name,
                                    "description": description
                                  });
                                }

                                if (action == 'update') {
                                  // Update the product
                                  await _tasks
                                      .doc(documentSnapshot!.id)
                                      .update({
                                    "name": name,
                                    "description": description
                                  });
                                }

                                // Clear the text fields
                                _nameController.text = '';
                                _descriptionController.text = '';

                                // Hide the bottom sheet
                                // ignore: use_build_context_synchronously
                                Navigator.of(context).pop();
                              }
                            },
                          )
                        ]))
                  ],
                ),
              )));
        });
  }

  // Deleting a product by id
  Future<void> _deleteProduct(String productId) async {
    await _tasks.doc(productId).delete();

    // Show a snackbar
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('You have successfully deleted a product')));
  }

  late final TextEditingController _controllerS;
  late final FocusNode _focusNode;
  String _terms = '';

  @override
  void initState() {
    super.initState();
    _controllerS = TextEditingController()..addListener(_onTextChanged);
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controllerS.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {
      _terms = _controllerS.text;
    });
  }

  Widget _buildSearchBox() {
    return Container(
      child: SearchBar(
        controller: _controllerS,
        focusNode: _focusNode,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    var fav = false;
    return Scaffold(
      /*
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_drop_down,
            size: 35,
          ),
          onPressed: (() {}),
        ),
        title: const Text(
          'Helix Todo',
          style: TextStyle(
              fontSize: 30,
              fontFamily: 'san-serif',
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic),
        ),
        centerTitle: true,
        toolbarOpacity: 0.9,
      ),*/
      // Using StreamBuilder to display all products from Firestore in real-time
      body: SafeArea(
        child: Column(children: [
          Container(
            margin: const EdgeInsets.fromLTRB(0, 2.5, 0, 0),
            width: screenWidth / 1.02,
            decoration: BoxDecoration(
              border: Border.all(),
              boxShadow: const [
                BoxShadow(
                  blurStyle: BlurStyle.normal,
                  blurRadius: 5,
                  color: Color.fromARGB(210, 22, 22, 22),
                )
              ],
              borderRadius: BorderRadius.circular(24),
              color: const Color.fromARGB(55, 22, 22, 22),
            ),
            child: Expanded(
              child: Row(
                children: [
                  SizedBox(
                    width: screenWidth / 1.03,
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            width: screenWidth / 5,
                            margin: const EdgeInsets.fromLTRB(1, 1, 1, 1),
                            child: IconButton(
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                size: 42,
                                color: const Color.fromARGB(185, 222, 222, 222),
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 5,
                          child: Container(
                              margin: const EdgeInsets.fromLTRB(0, 2.5, 0, 0),
                              decoration: BoxDecoration(
                                border: Border.all(),
                                boxShadow: const [
                                  BoxShadow(
                                    blurStyle: BlurStyle.normal,
                                    blurRadius: 5,
                                    color: Color.fromARGB(210, 22, 22, 22),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(24),
                                color: const Color.fromARGB(55, 22, 22, 22),
                              ),
                              child: _buildSearchBox()),
                        ),
                        Expanded(
                          flex: 1,
                          child: Container(
                            padding: const EdgeInsets.all(0),
                            margin: const EdgeInsets.fromLTRB(4, 2, 4, 2),
                            decoration: BoxDecoration(
                              border: Border.all(),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.person_outline,
                                size: 30,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 10,
            child: StreamBuilder(
              stream: _tasks.snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> streamSnapshot) {
                if (streamSnapshot.hasData) {
                  return SafeArea(
                      child: GridView.builder(
                    padding: const EdgeInsets.fromLTRB(5, 5, 5, 5),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1 / 1.3,
                    ),
                    itemCount: streamSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot documentSnapshot =
                          streamSnapshot.data!.docs[index];
                      return GestureDetector(
                          onLongPress: (() {}),
                          onTap: () => _createOrUpdate(documentSnapshot),
                          child: Container(
                              margin: const EdgeInsets.all(2),
                              width: screenWidth / 9,
                              decoration: BoxDecoration(
                                border: Border.all(),
                                boxShadow: const [
                                  BoxShadow(
                                    blurStyle: BlurStyle.normal,
                                    blurRadius: 5,
                                    color: Color.fromARGB(210, 22, 22, 22),
                                  )
                                ],
                                borderRadius: BorderRadius.circular(24),
                                color: const Color.fromARGB(55, 22, 22, 22),
                              ),
                              //Name of task/Desc and bottom icons column
                              child: Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      margin:
                                          const EdgeInsets.fromLTRB(0, 5, 0, 0),
                                      child: Text(
                                        documentSnapshot['name'],
                                        textAlign: TextAlign.center,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    //Desc Container
                                    Expanded(
                                        flex: 5,
                                        child: Container(
                                          margin: const EdgeInsets.fromLTRB(
                                              0, 4, 0, 0),
                                          padding: const EdgeInsets.fromLTRB(
                                              3, 4, 3, 2),
                                          width: screenWidth / 2.2,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: const Color.fromARGB(
                                                25, 22, 22, 22),
                                          ),
                                          child: Text(
                                            documentSnapshot['description']
                                                .toString(),
                                            style: const TextStyle(
                                                overflow: TextOverflow.fade,
                                                color: Color.fromARGB(
                                                    210, 200, 200, 200)),
                                          ),
                                        )),
                                    Expanded(
                                        child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.end,
                                            children: [
                                          IconButton(
                                              icon: Icon(
                                                Icons.favorite,
                                                size: 25,
                                                color: fav == true
                                                    ? const Color.fromARGB(
                                                        220, 220, 10, 10)
                                                    : const Color.fromARGB(
                                                        255, 220, 220, 220),
                                              ),
                                              onPressed: () => {
                                                    fav = true,
                                                  }),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.edit,
                                              size: 24,
                                              color: Color.fromARGB(
                                                  220, 220, 220, 120),
                                            ),
                                            onPressed: (() => _createOrUpdate(
                                                documentSnapshot)),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 25,
                                              color: Color.fromARGB(
                                                  170, 220, 10, 10),
                                            ),
                                            onPressed: (() => _deleteProduct(
                                                documentSnapshot.id)),
                                          ),
                                        ])),
                                  ],
                                ),
                              )));
                    },
                  ));
                }

                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
          ),
        ]),
      ),
      // Add new product
      floatingActionButton: FloatingActionButton(
        onPressed: () => _createOrUpdate(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
