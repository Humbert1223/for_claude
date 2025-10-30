import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_slideshow/flutter_image_slideshow.dart';
import 'package:novacole/models/master_crud_model.dart';

class HomeSlider extends StatefulWidget {
  const HomeSlider({super.key});

  @override
  HomeSliderState createState() => HomeSliderState();
}

class HomeSliderState extends State<HomeSlider> {
  List<Widget> _sliderItems = [];

  @override
  void initState() {
    super.initState();
    _loadAdvertisements();
  }

  Future<void> _loadAdvertisements() async {
    try {
      final data = await MasterCrudModel.load('/advertisement/sample');
      if (data != null && data.isNotEmpty && mounted) {
        final ads = List<Map<String, dynamic>>.from(data);
        setState(() {
          _sliderItems = ads
              .map((ad) => _buildSliderItem(ad['image_url'] as String))
              .toList();
        });
      }
    } catch (e) {
      if(kDebugMode){
        print(e);
      }
    }
  }

  Widget _buildSliderItem(String imageUrl) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha:0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16.0),
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey[200],
            child: const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey[300],
            child: const Icon(Icons.image_not_supported, color: Colors.grey),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_sliderItems.isEmpty) {
      return Container(
        height: 160,
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ImageSlideshow(
        indicatorColor: Theme.of(context).colorScheme.primary,
        indicatorBackgroundColor: Colors.white.withValues(alpha:0.5),
        indicatorPadding: 8,
        indicatorRadius: 5,
        height: 160,
        autoPlayInterval: 7000,
        isLoop: true,
        children: _sliderItems,
      ),
    );
  }
}