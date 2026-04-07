import 'package:flutter/material.dart';

class ParentalControlScreen extends StatefulWidget {
  @override
  _ParentalControlScreenState createState() => _ParentalControlScreenState();
}

class _ParentalControlScreenState extends State<ParentalControlScreen> {
  bool isParentalControlEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Parental Control'),
        backgroundColor: Colors.deepOrangeAccent,
        elevation: 2,
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        color: Colors.grey[100],
        child: Column(
          children: [
            // Card with gradient background
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: isParentalControlEnabled
                    ? LinearGradient(
                        colors: [Colors.orangeAccent, Colors.deepOrange],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [Colors.white, Colors.white],
                      ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: ListTile(
                leading: Icon(Icons.lock, size: 50, color: isParentalControlEnabled ? Colors.white : Colors.orange),
                title: Text(
                  'Parental Control',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isParentalControlEnabled ? Colors.white : Colors.black,
                  ),
                ),
                subtitle: Text(
                  isParentalControlEnabled ? 'Parental control is ON' : 'Parental control is OFF',
                  style: TextStyle(
                    color: isParentalControlEnabled ? Colors.white70 : Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                trailing: Switch(
                  value: isParentalControlEnabled,
                  onChanged: (value) {
                    setState(() {
                      isParentalControlEnabled = value;
                    });

                    // SnackBar feedback
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isParentalControlEnabled
                              ? 'Parental Control Enabled'
                              : 'Parental Control Disabled',
                        ),
                        duration: Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.orangeAccent.withOpacity(0.6),
                  inactiveThumbColor: Colors.orange,
                  inactiveTrackColor: Colors.orange[100],
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              'Parental control restricts access to certain content. Enable it to protect children from inappropriate content.',
              style: TextStyle(fontSize: 16, color: Colors.grey[700], height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}