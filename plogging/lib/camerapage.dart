import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:camera/camera.dart';

class CameraExample extends StatefulWidget {
  const CameraExample({Key? key}) : super(key: key);

  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  XFile? _image;
  final ImagePicker picker = ImagePicker();

  // 이미지를 가져오는 함수
  Future getImage(ImageSource imageSource) async {
    final XFile? pickedFile = await picker.pickImage(source: imageSource);
    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  // 이미지를 Firebase Storage에 업로드하는 함수
  Future<void> uploadImage() async {
    if (_image != null) {
      String fileName = path.basename(_image!.path);
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child("image/$fileName"); // "test" 폴더에 이미지 업로드

      UploadTask uploadTask = storageReference.putFile(File(_image!.path));

      uploadTask.whenComplete(() async {
        print('이미지 업로드 성공');

        final urlDownload = await uploadTask.snapshot.ref.getDownloadURL();
        print('url : ${urlDownload.toString()}');
      }).catchError((error) {
        print('이미지 업로드 실패: $error');
      });
    } else {
      print('이미지가 선택되지 않았습니다.');
    }
  }

  Widget _buildPhotoArea() {
    return _image != null
        ? SizedBox(
            width: 300,
            height: 300,
            child: Image.file(File(_image!.path)),
          )
        : Container(
            width: 300,
            height: 300,
            color: Colors.grey,
          );
  }

  Widget _buildButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.camera);
          },
          child: const Text("카메라"),
        ),
        const SizedBox(width: 30),
        ElevatedButton(
          onPressed: () {
            getImage(ImageSource.gallery);
          },
          child: const Text("갤러리"),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Camera Test")),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30, width: double.infinity),
            _buildPhotoArea(),
            const SizedBox(height: 20),
            _buildButton(),
            ElevatedButton(
              onPressed: uploadImage, // 이미지 업로드 함수 호출
              child: const Text("이미지 업로드"),
            ),
          ],
        ),
      ),
    );
  }
}
