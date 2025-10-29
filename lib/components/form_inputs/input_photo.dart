import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ModelFormInputPhoto extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function? onChange;

  const ModelFormInputPhoto({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
  });

  @override
  State createState() => _ModelFormInputPhotoState();
}

class _ModelFormInputPhotoState extends State<ModelFormInputPhoto> {
  dynamic _value;
  String? _name;

  @override
  void initState() {
    super.initState();
    _value = widget.initialValue;
    _name = widget.item['inputLabel'] ?? '';
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bc) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.photo_library_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text('Galerie'),
                  onTap: () {
                    _imgFromGallery();
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor.withValues(alpha:0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.camera_alt_rounded,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
                  title: const Text('Appareil photo'),
                  onTap: () {
                    _imgFromCamera();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _imgFromCamera() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        maxWidth: 1500,
        imageQuality: 100,
      );
      if (pickedFile != null) {
        setState(() {
          _value = pickedFile;
          _name = pickedFile.name;
        });
        widget.onChange?.call(_value, _name);
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  Future<void> _imgFromGallery() async {
    try {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _value = pickedFile;
          _name = pickedFile.name;
        });
        widget.onChange?.call(_value, _name);
      }
    } catch (e) {
      if (kDebugMode) print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8.0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              widget.item['name'],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _showPicker(context),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: _value != null
                    ? null
                    : LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor.withValues(alpha:0.1),
                    Theme.of(context).primaryColor.withValues(alpha:0.05),
                  ],
                ),
                border: Border.all(
                  color: Theme.of(context).primaryColor.withValues(alpha:0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).primaryColor.withValues(alpha:0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _value != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: _value.runtimeType == String
                    ? Image.network(_value, fit: BoxFit.cover)
                    : Image.file(
                  File((_value as XFile).path),
                  fit: BoxFit.cover,
                ),
              )
                  : Icon(
                Icons.camera_alt_rounded,
                color: Theme.of(context).primaryColor,
                size: 32,
              ),
            ),
          ),
        ],
      ),
    );
  }
}