import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:snapmug/core/class/colors.dart';

class GetPlaylistWidget extends StatefulWidget {
  final void Function()? ontap;
  final String playlistName;
  final bool isSelected;
  final String image;

  const GetPlaylistWidget({
    super.key,
    this.ontap,
    required this.playlistName,
    required this.isSelected,
    required this.image,
  });

  @override
  State<GetPlaylistWidget> createState() => _GetPlaylistWidgetState();
}

class _GetPlaylistWidgetState extends State<GetPlaylistWidget> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: CachedNetworkImage(
          imageUrl: widget.image,
          height: 60,
          width: 60,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) =>
              Icon(Icons.my_library_music_rounded),
        ),
      ),
      selected: widget.isSelected,
      selectedTileColor: AppColors.yellowColor, // لون خلفية عند التحديد
      selectedColor: AppColors.yellowColor, // لون النص عند التحديد
      title: Text(
        widget.playlistName,
        style: TextStyle(
          color: widget.isSelected
              ? Colors.black
              : Colors.white, // تأكيد تغيير لون النص
          fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: widget.ontap,
    );
  }
}
