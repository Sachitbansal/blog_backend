import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUpload extends StatefulWidget {
  @override
  State<ImageUpload> createState() => _ImageUploadState();
}

class _ImageUploadState extends State<ImageUpload> {
  // initializing some values
  List<XFile>? _image;
  final imagePicker = ImagePicker();
  String? downloadURL;

  // picking the image

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

  List<String> urls = [];
  int uploadItem = 0;
  var isUploading = false;


  void uploadFunction(List<XFile> images) async {
    setState(() {
      isUploading = true;
    });
    for (int i = 0; i < images.length; i++) {
      var imgUrl = await uploadFile(images[i]);
      urls.add(imgUrl.toString());
    }
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
          print(urls);
          urls.clear();
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
        title: const Text("Upload Image "),
      ),
      body: Center(
        child: isUploading
            ? const CircularProgressIndicator()
            : Padding(
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: SizedBox(
                        height: 500,
                        width: double.infinity,
                        child: Column(children: [
                          const Text("Upload Image"),
                          const SizedBox(
                            height: 10,
                          ),
                          Expanded(
                            flex: 4,
                            child: Container(
                              width: 300,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.red),
                              ),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    // the image that we wanted to upload
                                    Expanded(
                                        child: _image == null
                                            ? const Center(
                                                child:
                                                    Text("No image selected"))
                                              : ListView.builder(
                                                  scrollDirection:
                                                      Axis.horizontal,
                                                  itemCount: _image!.length,
                                                  itemBuilder: (context, index) {
                                                    return Semantics(
                                                      child: Row(
                                                        children: [
                                                          Image.file(
                                                            File(_image![index]
                                                                .path),
                                                          ),
                                                          const SizedBox(
                                                            width: 10,
                                                          )
                                                        ],
                                                      ),
                                                    );
                                                  },
                                                )),
                                    ElevatedButton(
                                        onPressed: () {
                                          imagePickerMethod();
                                        },
                                        child: const Text("Select Image")),
                                    ElevatedButton(
                                        onPressed: () {
                                          if (_image != null) {
                                            uploadFunction(_image!);
                                          } else {
                                            showSnackBar(
                                                "Select Image first",
                                                const Duration(
                                                    milliseconds: 400));
                                          }
                                        },
                                        child: const Text("Upload Image")),
                                  ],
                                ),
                              ),
                            ),
                          )
                        ])))),
      ),
    );
  }

  // show snack bar

  showSnackBar(String snackText, Duration d) {
    final snackBar = SnackBar(content: Text(snackText), duration: d);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
