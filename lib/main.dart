import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
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
      debugShowCheckedModeBanner: false,
      title: 'CDC template',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrangeAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Test di utilizzo del dispositivo CDC'),
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

    String update="";
    List<Widget> serialData=[];
    //controlla che non siano nulli; va messa fuori per fare la chiusura al termine della app
    UsbPort? port;

  Future<void> read() async {
    //lista tutti i devices che ci sono
    List<UsbDevice> devices = await UsbSerial.listDevices();

    //controlla che nn siano nulli
    UsbPort? port;
    if (devices.length == 0) {
      return;
    }

    //crea una porta; se la lettura va fatta da più dispositivi com questa $port deve essere una lista
    port = await devices[0].create();

    //apri la/e porta/e
    bool openResult = await port!.open();
    if ( !openResult ) {
      print("Failed to open");
      return;
    }

    await port.setDTR(true);
    await port.setRTS(true);

    //questi sono i parametri di lettura delle porte COM/CDM, si può cambiare qui o direttamente dal dispositivo
    port.setPortParameters(115200, UsbPort.DATABITS_8,
        UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);

    await port.write(Uint8List.fromList([0x01, 0x54, 0x04]));

    //leggi dalla porta e fai una traduzione da Uint8List a Stringa in questo caso
    port.inputStream!.listen((Uint8List event) {
      print(event);
      setState(() {
        String s = new String.fromCharCodes(event); /// <-molto importante
        update="$s";
        serialData.add(Text(s));
      });
    });

    //01 54 04 apertura
    // 01 50 04 chiusura
    //questi numeri sono esadecimali per istruzioni al dispositivo com; riferite al dispositivo 0x1EAB/0x1D06: NewLand;
  }


    @override
    void dispose() {
      super.dispose();
    //chiusura della porta
      port!.close();
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
            Text(update),
            ...serialData,
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
