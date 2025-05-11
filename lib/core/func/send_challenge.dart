import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:snapmug/pages/BottomNav/Home.dart';

showAW(
  BuildContext context,
  TextEditingController linkController,
  void Function()? ontap,
  void Function(DismissType)? onDismissCallback,
) {
  AwesomeDialog(
      onDismissCallback: onDismissCallback,
      dialogType: DialogType.noHeader,
      context: context,
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          spacing: 10,
          children: [
            TextFormField(
              controller: linkController,
              decoration: InputDecoration(
                hintText: 'Enter your link',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: yellowColor),
                ),
              ),
            ),
            GestureDetector(
                onTap: ontap,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: BorderRadius.circular(10)),
                  child: Text("Send"),
                )),
          ],
        ),
      )).show();
}
