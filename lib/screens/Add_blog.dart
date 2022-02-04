import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddBlog extends StatefulWidget {
  const AddBlog({Key? key}) : super(key: key);

  @override
  _AddBlogState createState() => _AddBlogState();
}

class _AddBlogState extends State<AddBlog> {
  CollectionReference students = FirebaseFirestore.instance.collection('blog');

  Future<void> addUser() {
    return students.add({
      'image': urls,
      'description': description,
      'date': date,
      'title': title,
    }).then(
      (value) => {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Added Successfully'),
          ),
        ),
      },
    );
  }

  final _formKey = GlobalKey<FormState>();

  late String date = 'None';
  late String title = 'None';
  late String description = 'None';

  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  @override
  void dispose() {
    dateController.dispose();
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  List<XFile>? _image;
  final imagePicker = ImagePicker();
  List<String> downloadURL = [];
  List<String> urls = [];
  int uploadItem = 0;
  var isUploading = false;

  Future imagePickerMethod() async {
    final pick = await imagePicker.pickMultiImage();
    setState(() {
      if (pick != null) {
        _image = pick;
      } else {
        showSnackBar("No File selected", const Duration(milliseconds: 400));
      }
    });
  }

  void uploadFunction(List<XFile> images) async {
    setState(() {
      isUploading = true;
    });
    for (int i = 0; i < images.length; i++) {
      var imgUrl = await uploadFile(images[i]);
      urls.add(imgUrl.toString());
    }

    addUser().whenComplete(() {urls.clear();});
  }

  Future<String> uploadFile(XFile images) async {
    final imgId = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child("post_$imgId");
    UploadTask uploadTask = reference.putFile(File(images.path));
    await uploadTask.whenComplete(() {
      setState(() {
        uploadItem++;
        if (uploadItem == _image!.length) {
          isUploading = false;
          uploadItem = 0;
        }
      });
    });
    // print(await reference.getDownloadURL());
    return await reference.getDownloadURL();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Blog'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child:  isUploading
              ? const CircularProgressIndicator()
              : Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              children: [
                CustomTextField(
                    titleController: dateController, labelText: 'Date'),
                CustomTextField(
                    titleController: titleController, labelText: 'Title'),
                CustomTextField(
                    titleController: descriptionController,
                    labelText: 'Description'),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Expanded(
                          flex: 4,
                          child: Container(
                            width: 300,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.blue),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: _image == null
                                        ? const Center(
                                            child: Text("No image selected"),
                                          )
                                        : ListView.builder(
                                            scrollDirection: Axis.horizontal,
                                            itemCount: _image!.length,
                                            itemBuilder: (context, index) {
                                              return Semantics(
                                                child: Row(
                                                  children: [
                                                    Image.file(
                                                      File(_image![index].path),
                                                    ),
                                                    const SizedBox(
                                                      width: 10,
                                                    )
                                                  ],
                                                ),
                                              );
                                            },
                                          ),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      imagePickerMethod();
                                    },
                                    child: const Text("Select Image"),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.blue[200]!),
                    alignment: Alignment.center,
                  ),
                  child: SizedBox(
                    height: 40,
                    width: MediaQuery.of(context).size.width * .8,
                    child: const Center(
                      child: Text(
                        'Upload To Firebase',
                        style: TextStyle(color: Colors.white, fontSize: 20),
                      ),
                    ),
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate() && _image != null) {
                      setState(() {
                        date = dateController.text;
                        title = titleController.text;
                        description = descriptionController.text;
                      });
                      uploadFunction(_image!);
                    } else {
                      showSnackBar("Select Image first",
                          const Duration(milliseconds: 400));
                    }
                  },
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  const CustomTextField({
    Key? key,
    required this.titleController,
    required this.labelText,
    this.validator,
  }) : super(key: key);

  final TextEditingController titleController;
  final String labelText;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      cursorColor: Colors.blue[300],
      decoration: InputDecoration(
        isCollapsed: true,
        fillColor: Colors.blue[200]?.withOpacity(0.05),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 15.0, horizontal: 10),
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(5),
          borderSide: const BorderSide(width: 0.8),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            width: 0.8,
            color: Colors.blue[300]!,
          ),
        ),
        labelText: labelText,
      ),
      controller: titleController,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Field Can\'t be empty';
        }
        return null;
      },
    );
  }
}
