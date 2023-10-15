import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_crud/services/firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Firestore service
  final FirestoreService firestoreService = FirestoreService();

  // Text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog box to add a note
  void openNoteBox({String? docId}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: const Text("Add Note"),
                content: TextField(
                  controller: textController,
                ),
                actions: [
                  // button to save
                  ElevatedButton(
                    onPressed: () {
                      // add a new note
                      if (docId == null) {
                        firestoreService.addNote(textController.text);
                      }
                      // update existing note
                      else {
                        firestoreService.updateNote(docId, textController.text);
                      }
                      // clear the text controller
                      textController.clear();
                      // close the modal
                      Navigator.pop(context);
                    },
                    child: Text("Add"),
                  )
                ]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Notes")),
      floatingActionButton: FloatingActionButton(
          onPressed: openNoteBox, child: const Icon(Icons.add)),
      body: StreamBuilder<QuerySnapshot>(
        stream: firestoreService.getNotesStream(),
        builder: (context, snapshot) {
          // if we have all the data, get all the notes
          if (snapshot.hasData) {
            List notesList = snapshot.data!.docs;

            // display as a list
            return ListView.builder(
              itemCount: notesList.length,
              itemBuilder: (context, index) {
                // get each individual doc
                DocumentSnapshot document = notesList[index];
                String docId = document.id;
                // get note from each doc
                Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                String noteText = data['note'];
                // display as a list tile
                return ListTile(
                  title: Text(noteText),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    // update button
                    IconButton(
                      onPressed: () => openNoteBox(docId: docId),
                      icon: const Icon(Icons.settings),
                    ),
                    // delete button
                    IconButton(
                      onPressed: () => firestoreService.deleteNote(docId),
                      icon: const Icon(Icons.delete),
                    )
                  ]),
                );
              },
            );
          }
          // if there is no data return nothing
          else {
            return const Text("No data...");
          }
        },
      ),
    );
  }
}
