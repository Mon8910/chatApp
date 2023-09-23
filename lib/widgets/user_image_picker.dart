import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserImagePicker extends StatefulWidget {
  const UserImagePicker({super.key,required this.onselectedimage});
  final void Function(File pickedimage) onselectedimage;
  @override
  State<UserImagePicker> createState() {
    return _UserImagePickerState();
  }
}

class _UserImagePickerState extends State<UserImagePicker> {
  File? pickedimagefile;
  void _pickedimage() async {
    final pikedimages = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 50, maxWidth: 150);
    if (pikedimages == null) {
      return null;
    }
    setState(() {
      pickedimagefile = File(pikedimages.path);
    });
    widget.onselectedimage(pickedimagefile!);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: Colors.grey,
          foregroundImage:
              pickedimagefile != null ? FileImage(pickedimagefile!) : null,
        ),
        TextButton.icon(
          onPressed: _pickedimage,
          label: Text(
            'add image ',
            style: TextStyle(color: Theme.of(context).primaryColor),
          ),
          icon: const Icon(Icons.image),
        )
      ],
    );
  }
}
