import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:usb_serial/transaction.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:flutter/cupertino.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;
  String update="";
  String debuggo="debugo";

  Future<void> read() async {
    List<UsbDevice> devices = await UsbSerial.listDevices();
    print(devices);

    UsbPort? port;
    if (devices.length == 0) {
      return;
    }
    port = await devices[0].create();

    bool openResult = await port!.open();
    if ( !openResult ) {
      print("Failed to open");
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    port.setPortParameters(115200, UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    // print first result and close port.
    port.inputStream!.listen((Uint8List event) {
      print(event);
      setState(() {
        String s = new String.fromCharCodes(event);
        var outputAsUint8List = new Uint8List.fromList(s.codeUnits);
        update="$s";
      });
      //port!.close();
    });

    //01 54 04 apertura
    // 01 50 04 chiusura
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(update),
            Text(debuggo),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: read,
        tooltip: 'read',
        child: const Icon(Icons.track_changes),
      ),
    );
  }
}
