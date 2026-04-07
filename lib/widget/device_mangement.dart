import 'package:flutter/material.dart';

class DeviceManagementScreen extends StatelessWidget {
  final String connectedDeviceName;
  final String deviceType;

  DeviceManagementScreen({
    required this.connectedDeviceName,
    this.deviceType = 'TV', // default type
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Device Management'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: connectedDeviceName.isNotEmpty
            ? Column(
                children: [
                  Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    elevation: 4,
                    child: ListTile(
                      leading: Icon(Icons.tv, size: 40, color: Colors.blue),
                      title: Text(
                        connectedDeviceName,
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text('Connected $deviceType'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          // Disconnect device logic
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Disconnect Device?'),
                              content: Text(
                                  'Do you want to disconnect $connectedDeviceName?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Call your disconnect function here
                                    Navigator.pop(context);
                                  },
                                  child: Text('Disconnect'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text('Disconnect'),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Only one device can be connected at a time.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            : Center(
                child: Text(
                  'No devices connected',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
      ),
    );
  }
}