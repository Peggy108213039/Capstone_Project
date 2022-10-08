import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';

class TakePhotoPage extends StatefulWidget {
  const TakePhotoPage({Key? key}) : super(key: key);

  @override
  State<TakePhotoPage> createState() => _TakePhotoPageState();
}

class _TakePhotoPageState extends State<TakePhotoPage> {
  File? imageFile;

  void getFromCamera() async {
    XFile? pickedFile = await ImagePicker()
        .pickImage(source: ImageSource.camera, maxHeight: 1080, maxWidth: 1080);
    imageFile = File(pickedFile!.path);
    // 存到手機的相簿中
    await GallerySaver.saveImage(imageFile!.path).then((bool? saveSuccess) {
      print('save successful');
    });
    print('imageFile path ${imageFile!.path}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(children: [
        const SizedBox(
          height: 50,
        ),
        (imageFile != null)
            ? Container(
                child: Image.file(imageFile!),
              )
            : Container(
                child: const Icon(
                  Icons.camera_alt_outlined,
                  color: Colors.indigo,
                  size: 50,
                ),
              ),
        Padding(
          padding: const EdgeInsets.all(30),
          child: ElevatedButton(
            child: const Text('Capture Image with Camera'),
            onPressed: () {
              getFromCamera();
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all(Colors.indigo),
                padding: MaterialStateProperty.all(const EdgeInsets.all(12)),
                textStyle:
                    MaterialStateProperty.all(const TextStyle(fontSize: 16))),
          ),
        )
      ]),
    );
  }
}
