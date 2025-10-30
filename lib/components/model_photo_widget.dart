import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart' as getX;
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:novacole/components/empty_page.dart';
import 'package:novacole/components/loading_indicator.dart';
import 'package:novacole/controllers/auth_controller.dart';
import 'package:novacole/models/master_crud_model.dart';
import 'package:novacole/models/user_model.dart';
import 'package:novacole/utils/api.dart';
import 'package:novacole/utils/permission_utils.dart';

class ModelPhotoWidget extends StatefulWidget {
  final Function? onSave;
  final Map<String, dynamic> model;
  final double? width;
  final double? height;
  final String? photoKey;
  final double? editIconSize;
  final bool? editable;
  final BorderRadiusGeometry? borderRadius;

  const ModelPhotoWidget({
    super.key,
    required this.model,
    this.width,
    this.height,
    this.borderRadius,
    this.editIconSize,
    this.onSave,
    this.editable = true,
    this.photoKey,
  });

  @override
  ModelPhotoWidgetState createState() {
    return ModelPhotoWidgetState();
  }
}

class ModelPhotoWidgetState extends State<ModelPhotoWidget> {
  File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  late final Dio _dio;
  bool _isUploading = false;
  final authController = getX.Get.find<AuthController>();

  @override
  void initState() {
    super.initState();
    Http().api().then((dio) {
      setState(() {
        _dio = dio;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      File? croppedImage = await _cropImage(File(pickedFile.path));

      if (croppedImage != null) {
        setState(() {
          _imageFile = croppedImage;
        });

        await _uploadAndSaveImage(_imageFile!);
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
        ),
      ],
    );

    if (croppedFile != null) {
      return File(croppedFile.path);
    }
    return null;
  }

  Future<void> _uploadAndSaveImage(File image) async {
    setState(() {
      _isUploading = true;
    });

    try {
      String fileExt = image.path.split('.').last;
      String fileName = "${widget.model['full_name'].toString()}.$fileExt";

      FormData formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(image.path, filename: fileName),
      });
      var response = await _dio.post('/uploads', data: formData);

      if (response.statusCode == 200) {
        final photoUrl = response.data['path'];
        _updatePhoto(photoUrl);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    color: Colors.white,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Image téléversée avec succès',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green.shade600,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 6,
            ),
          );
        }
      } else {
        _showErrorSnackBar('Échec du téléversement de l\'image');
      }
    } catch (e) {
      _showErrorSnackBar('Erreur lors du téléversement');
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.white,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.red.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 6,
        ),
      );
    }
  }

  Future<void> _updatePhoto(path) {
    return MasterCrudModel(widget.model['entity'])
        .update(widget.model['id'], {
      'form_id': widget.model['form_id'],
      'entity': widget.model['entity'],
      'photo': path,
    })
        .then((onValue) {
      if (widget.onSave != null) {
        widget.onSave!(onValue);
      }
      setState(() {
        widget.model['photo'] = path;
        widget.model[widget.photoKey ?? 'photo_url'] =
        onValue?[widget.photoKey ?? 'photo_url'];
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Stack(
      children: [
        Container(
          height: widget.height ?? 90,
          width: widget.width ?? 90,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Image
                _buildImage(),
                // Overlay de chargement
                if (_isUploading)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      borderRadius: widget.borderRadius ?? BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            strokeWidth: 3,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Téléversement...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        // Bouton d'édition moderne
        if (widget.editable == true &&
            authController.currentUser.value!.hasPermissionSafe(
              PermissionName.update(widget.model['entity']),
            ))
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: () => _showImageSourceActionSheet(context),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withValues(alpha: 0.8),
                    ],
                  ),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.scaffoldBackgroundColor,
                    width: 2.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withValues(alpha: 0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.edit_rounded,
                  color: Colors.white,
                  size: widget.editIconSize ?? 16,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildImage() {
    if (widget.model[widget.photoKey ?? 'photo_url'] != null) {
      return CachedNetworkImage(
        imageUrl: widget.model[widget.photoKey ?? 'photo_url'],
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: Colors.grey.shade200,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        errorWidget: (context, url, error) => Container(
          color: Colors.grey.shade200,
          child: Icon(
            Icons.person,
            size: (widget.width ?? 90) * 0.5,
            color: Colors.grey.shade400,
          ),
        ),
      );
    } else if (_imageFile != null) {
      return Image.file(
        _imageFile!,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        'assets/images/image.png',
        fit: BoxFit.cover,
      );
    }
  }

  void _showImageSourceActionSheet(BuildContext context) {
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Container(
                  margin: EdgeInsets.only(top: 12, bottom: 20),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Titre
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add_photo_alternate_rounded,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                      ),
                      SizedBox(width: 12),
                      Text(
                        'Choisir une image',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleLarge?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Options
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.cloud_done_outlined,
                  title: 'Images téléversées',
                  subtitle: 'Choisir parmi les images existantes',
                  color: Colors.purple,
                  onTap: () {
                    Navigator.of(context).pop();
                    _showUploadedImages(context);
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.photo_library_rounded,
                  title: 'Galerie',
                  subtitle: 'Sélectionner depuis la galerie',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildImageSourceOption(
                  context: context,
                  icon: Icons.camera_alt_rounded,
                  title: 'Appareil photo',
                  subtitle: 'Prendre une nouvelle photo',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.of(context).pop();
                    _pickImage(ImageSource.camera);
                  },
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildImageSourceOption({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: color,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showUploadedImages(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.8,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
              ),
              child: Column(
                children: [
                  // Handle bar
                  Container(
                    margin: EdgeInsets.only(top: 12, bottom: 10),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Header
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Images téléversées',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1),
                  // Images grid
                  Expanded(
                    child: FutureBuilder(
                      future: MasterCrudModel('upload').search(
                        paginate: '0',
                        filters: [
                          {
                            'field': 'type',
                            'operator': 'like',
                            'value': 'image/',
                          },
                        ],
                      ),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: LoadingIndicator());
                        } else if (snap.hasData) {
                          return _uploadImageList(snap.data, scrollController);
                        } else {
                          return const Center(child: EmptyPage());
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _uploadImageList(list, ScrollController scrollController) {
    final images = List<Map<String, dynamic>>.from(list);

    return GridView.builder(
      controller: scrollController,
      padding: EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1,
      ),
      itemCount: images.length,
      itemBuilder: (context, index) {
        final upload = images[index];
        return _buildUploadedImageItem(upload);
      },
    );
  }

  Widget _buildUploadedImageItem(Map<String, dynamic> upload) {
    return InkWell(
      onTap: () {
        Navigator.of(context).pop();
        _updatePhoto(upload['path']);
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14.5),
          child: upload['url'] != null
              ? CachedNetworkImage(
            imageUrl: upload['url'],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey.shade200,
              child: Center(
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey.shade400,
              ),
            ),
          )
              : Image.asset(
            'assets/images/person.jpeg',
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}