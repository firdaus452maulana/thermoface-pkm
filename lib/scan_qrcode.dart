import 'dart:async';

//import 'package:face_recognition/setting.dart';
import 'package:flutter/material.dart';
import 'result_scan.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanQrCode extends StatefulWidget {
  @override
  _ScanQrCodeState createState() => _ScanQrCodeState();
}

class _ScanQrCodeState extends State<ScanQrCode> {
  final qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController controller;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          buildQrView(context),
        ],
      ),
    );
  }

  Widget buildQrView(BuildContext context) => QRView(
        key: qrKey,
        onQRViewCreated: onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).accentColor,
          borderRadius: 10,
          borderLength: 20,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.6,
        ),
      );

  void onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      controller.flipCamera();
      Timer(Duration(seconds: 10), () {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResultScan(
                      data: "Pengunjung",
                    )));
      });
    });

    controller.scannedDataStream.listen((barcode) {
      setState(() {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ResultScan(
                      data: barcode.code,
                    )));
      });
    });
  }
}
