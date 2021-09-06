import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:konnect/widgets/image_input.dart';

class EditViewPhotoPage extends StatelessWidget {
  final Function chooseInputDialog;
  final Function toEditImage;
  final File storedImage;

  const EditViewPhotoPage(
      {@required this.toEditImage,
      @required this.storedImage,
      this.chooseInputDialog});
  @override
  Widget build(BuildContext context) {
    File imageFile;
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text('Profile photo'),
          actions: [
            IconButton(
                icon: Icon(
                  Icons.edit,
                  color: Colors.white,
                ),
                onPressed: () async {
                  PhotoInputType inputType = await chooseInputDialog();
                  if (inputType == null) return;
                  imageFile = inputType == PhotoInputType.camera
                      ? await toEditImage(ImageSource.camera)
                      : await toEditImage(ImageSource.gallery);
                  Navigator.pop(context, imageFile);
                }),
          ],
        ),
        backgroundColor: Colors.black,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              child: Image.file(
                storedImage,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            )
          ],
        ),
      ),
    );
  }
}
