import 'package:band_names/services/socket.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final socketService = Provider.of<SocketService>(context);
    return Scaffold(
      body: Center(
        child: Text('Server Status: ${socketService.serverStatus} '),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.message),
        onPressed: () {
          //emit a Map {name: ''}
          socketService.emit('emit-message', {'name': 'Ezequiel Jaramillo'});
        },
      ),
    );
  }
}
