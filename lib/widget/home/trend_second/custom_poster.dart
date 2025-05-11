import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snapmug/pages/artist_page.dart';
import 'package:snapmug/widget/home/paint_trend.dart';

class CustomPosterTrendSecond extends StatelessWidget {
  final String imageCover;
  final String imageArtist;
  final String artistId;
  const CustomPosterTrendSecond(
      {super.key,
      required this.imageCover,
      required this.imageArtist,
      required this.artistId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: Get.width * 0.2,
      height: Get.height * 0.1,
      decoration: BoxDecoration(),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          SizedBox(
            // width: Get.width * 0.15,
            // height: Get.height * 0.5,
            child: ClipPath(
              clipper: CustomShapeClipper(borderRadius: 20),
              child: CachedNetworkImage(
                imageUrl: imageCover,
                width: Get.width * 0.2,
                height: Get.height * 0.1,
                fit: BoxFit.cover,
              ),
            ),
          ),
          CustomPaint(
            painter: RPSCustomPainter(
                borderRadius: 20), // يمكنك تغيير قيمة borderRadius هنا
            size: Size(Get.width * 0.2, Get.height * 0.1),
          ),
          Positioned(
            top: -20,
            right: Get.width * 0.11,
            child: InkWell(
              onTap: () {
                Get.to(ArtistPage(), arguments: artistId);
              },
              child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Color(0xff928989),
                      width: 2,
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CachedNetworkImage(
                      height: Get.height * 0.04,
                      width: Get.width * 0.08,
                      fit: BoxFit.cover,
                      imageUrl: imageArtist,
                      errorWidget: (context, url, error) {
                        print("========================================");
                        print(imageArtist);
                        return CachedNetworkImage(
                            height: Get.height * 0.05,
                            width: Get.width * 0.1,
                            fit: BoxFit.cover,
                            imageUrl: imageCover);
                      },
                    ),
                  )),
            ),
          ),
        ],
      ),
    );
  }
}
