import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ImageUtil {
  /// Returns byte list of selected image, or null if no image was selected
  static Future<Uint8List?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null) {
      return result.files.single.bytes;
    } else {
      return null;
    }
  }

  /// Returns list of byte lists of selected images, or null if no image was selected
  static Future<List<Uint8List>?> pickImages(int maxImages) async {
    List<Uint8List> images = [];
    FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.image);
    if (result != null) {
      List<PlatformFile> files = result.files.toList();
      if (files.length > maxImages) {
        files = files.sublist(0, maxImages);
      }
      for (PlatformFile file in files) {
        images.add(file.bytes!);
      }
      return images;
    } else {
      return null;
    }
  }

  //Not yet tested for web
  static Future<Uint8List?> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      return result.files.single.bytes;
    } else {
      return null;
    }
  }

  static Future<String> uploadImageToDefaultBucket(Uint8List image, String storagePath,
      {int minHeight = 700, int minWidth = 700, int quality = 85}) async {
    // There doesn't seem to be a good solution for web yet. Could upload the file to a CF first and compress it there.
    /* var result = await FlutterImageCompress.compressWithFile(
      image.absolute.path,
      minHeight: minHeight,
      minWidth: minWidth,
      quality: quality,
    );*/

    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(storagePath);
    UploadTask uploadTask = firebaseStorageRef.putData(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot.ref.getDownloadURL();
  }

  static Future<String> uploadVideoToDefaultBucket(File video, String storagePath) async {
    Reference firebaseStorageRef = FirebaseStorage.instance.ref().child(storagePath);
    UploadTask uploadTask = firebaseStorageRef.putFile(video);
    TaskSnapshot taskSnapshot = await uploadTask;
    return taskSnapshot.ref.getDownloadURL();
  }
}
