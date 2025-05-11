import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapmug/model/artist_model.dart';

import '../../core/class/colors.dart';

class ImagesWidget extends StatelessWidget {
  final ArtistModel artist;
  const ImagesWidget({super.key, required this.artist});

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Padding(
          padding: EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: CachedNetworkImage(
              height: Get.height * 0.25,
              width: Get.width,
              fit: BoxFit.cover,
              imageUrl: artist.profilePicture,
              placeholder: (context, url) =>
                  const Center(child: CircularProgressIndicator()),
              errorWidget: (context, url, error) => CachedNetworkImage(
                  imageUrl:
                      'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          left: 25,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100),
              border: Border.all(
                color: AppColors.yellowColor,
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: CachedNetworkImage(
                fit: BoxFit.cover,
                height: Get.height * 0.13,
                width: Get.width * 0.27,
                imageUrl: artist.profilePicture,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => CachedNetworkImage(
                    imageUrl:
                        'https://firebasestorage.googleapis.com/v0/b/snapmug-54ade.appspot.com/o/tmpp%2Fwell.jpeg?alt=media&token=1749d61b-734b-4739-b9e1-e5daefcbb500'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
