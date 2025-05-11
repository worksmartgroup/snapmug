import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';

createPlaylist(BuildContext context, TextEditingController controller,
    void Function()? ontap) {
  return AwesomeDialog(
    context: context,
    animType: AnimType.scale,
    dialogType: DialogType.noHeader,
    body: Column(
      children: [
        Text(
          'write the name of the playlist',
          style: TextStyle(fontStyle: FontStyle.italic, fontSize: 20),
        ),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Playlist Name',
          ),
        ),
      ],
    ),
    title: 'This is Ignored',
    desc: 'This is also Ignored',
    btnOkOnPress: ontap,
  )..show();
}
