import 'package:flutter/material.dart';
import 'package:snapmug/pages/TransactionHistory.dart';

import 'BottomNav/Home.dart';

class BalanceActivity extends StatefulWidget {
  @override
  _BalanceActivityState createState() => _BalanceActivityState();
}

class _BalanceActivityState extends State<BalanceActivity> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF141118),
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text(
          'SnapMug Wallet',
          style: TextStyle(
            color: yellowColor,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: yellowColor),
          onPressed: () {
            // handle back button press
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WithdrawalsActivity(),
                ),
              );
              // Add your settings button functionality here
            },
            color: yellowColor,
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(
            height: 10,
          ),
          Card(
            color: Color(0xFF221E10),
            margin: EdgeInsets.symmetric(horizontal: 10),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Color(0xFF4e4b53), width: 1.0),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Balance Ushs',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        '0.00',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white,
                    thickness: 0.5,
                  ),
                  Row(
                    children: [
                      Text(
                        'Mobile Money Number',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        'phone number',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                  Divider(
                    color: Colors.white,
                    thickness: 0.5,
                  ),
                  Row(
                    children: [
                      Text(
                        'Mobile Money Name',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      Spacer(),
                      Text(
                        'Name',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Used Sounds',
              style: TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: 10, // replace with your data length
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text('Item $index'),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // handle withdraw button press
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(Icons.attach_money),
                  Text(
                    'Withdraw',
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
