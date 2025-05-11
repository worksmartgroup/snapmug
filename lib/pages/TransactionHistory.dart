import 'package:flutter/material.dart';

import 'BottomNav/Home.dart';

class WithdrawalsActivity extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141118),
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: yellowColor,
        ),
        title: Text(
          'My Withdrawals',
          style: TextStyle(
            color: yellowColor,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: 0, // Add your item count here
              itemBuilder: (context, index) {
                // Add your list item widget here
                return Container();
              },
            ),
          ),
          Visibility(
            visible: true, // Set visibility based on data availability
            child: Container(
              padding: EdgeInsets.all(10),
              alignment: Alignment.center,
              child: Text(
                'No Transactions Yet',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
