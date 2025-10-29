import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/models/master_crud_model.dart';

class ModelFormInputUpload extends StatefulWidget {
  final Map<String, dynamic> item;
  final dynamic initialValue;
  final Function? onChange;

  const ModelFormInputUpload({
    super.key,
    required this.item,
    this.initialValue,
    this.onChange,
  });

  @override
  State createState() {
    return _ModelFormInputUploadState();
  }
}

class _ModelFormInputUploadState extends State<ModelFormInputUpload> {
  dynamic _value;
  String _name = "";
  File? _pickedFile;
  final ImagePicker _imagePicker = ImagePicker();
  late final Dio _dio;

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _imagePicker.pickImage(source: source);

    if (pickedFile != null) {
      File? croppedImage = await _cropImage(File(pickedFile.path));

      if (croppedImage != null) {
        setState(() {
          _pickedFile = croppedImage;
        });

        await _uploadAndSaveImage(_pickedFile!);
      }
    }
  }

  Future<void> _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      if (result.files.single.path != null) {
        String? path = result.files.single.path;
        if(path != null){
          _pickedFile = File(path);
          if (_pickedFile != null) {
            await _uploadAndSaveImage(_pickedFile!);
          }
        }
      }
    }

  }

  Future<File?> _cropImage(File imageFile) async {
    CroppedFile? croppedFile = await ImageCropper().cropImage(
      sourcePath: imageFile.path,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1.3),
      maxHeight: 800,
      maxWidth: 800,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Recadrer l\'image',
          toolbarColor: Colors.blue,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: true,
        )
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _uploadAndSaveImage(File image) async {
    try {
      String fileExt = image.path.split('.').last;
      String fileName = "${widget.item['name'].toString()}.$fileExt";

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });
      var response = await _dio.post('/uploads', data: formData);

      if (response.statusCode == 200) {
        final photoUrl = response.data['path'];
        if(widget.onChange != null){
          setState(() {
            _name = photoUrl;
          });
          widget.onChange!(photoUrl);
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Échec du téléversement de l\'image',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Erreur lors du téléversement',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _uploadImageList(list) {
    return GridView.count(
      crossAxisCount: 3,
      primary: false,
      shrinkWrap: true,
      children: List<Map<String, dynamic>>.from(list).map<Widget>((upload) {
        return Card(
          child: InkWell(
            onTap: (){
              Navigator.of(context).pop();
              if(widget.onChange != null){
                setState(() {
                  _name = upload['path'];
                });
                widget.onChange!(upload['path']);
              }
            },
            child: Container(
              margin: const EdgeInsets.all(5),
              height: 90,
              width: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: (upload['url'] != null)
                    ? DecorationImage(
                  image: CachedNetworkImageProvider(upload['url']),
                  fit: BoxFit.cover,
                )
                    : const DecorationImage(
                  image: AssetImage('assets/images/person.jpeg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showImageSourceActionSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.cloud_done_outlined),
                title: const Text('Fichiers téléversés'),
                onTap: () {
                  Navigator.of(context).pop();
                  showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      builder: (context) {
                        return FutureBuilder(
                            future: MasterCrudModel('upload').search(
                              paginate: '0'
                            ),
                            builder: (context, snap) {
                              if (snap.connectionState ==
                                  ConnectionState.waiting) {
                                return const Center(child: LoadingIndicator());
                              } else {
                                if (snap.hasData) {
                                  return _uploadImageList(snap.data);
                                } else {
                                  return const Center(
                                    child: EmptyPage(),
                                  );
                                }
                              }
                            });
                      });
                },
              ),
              ListTile(
                leading: const Icon(Icons.file_copy_sharp),
                title: const Text('Documents'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickFile();
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Galerie'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Appareil photo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void initState() {
    _value = widget.initialValue;
    _name = widget.item['inputLabel'] ?? '';
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.item['name']),
            _value != null
                ? SizedBox(
                    width: MediaQuery.of(context).size.width / 1.5,
                    child: Text(
                      _name,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 11,
                      ),
                      overflow: TextOverflow.fade,
                    ),
                  )
                : const Text(
                    'Sélectionner un fichier',
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 11,
                    ),
                  ),
          ],
        ),
        GestureDetector(
          onTap: () => _showImageSourceActionSheet(context),
          child: Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Theme.of(context).colorScheme.primary),
            ),
            child: Icon(
              Icons.upload_file,
              color: Colors.grey[800],
              size: 35,
            ),
          ),
        ),
      ],
    );
  }
}
