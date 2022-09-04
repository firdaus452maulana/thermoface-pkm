import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';
import 'package:face_recognition/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:face_recognition/setconstorage.dart';

class Setting extends StatefulWidget {
  var state = SettingState();

  @override
  SettingState createState() {
    return this.state = new SettingState();
  }
}

class SettingState extends State<Setting> {
  /// tanggal 18 agustus 2020
  // static SettingState instance = new SettingState();
  static SettingState instance;

  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Initializing a global key, as it would help us in showing a SnackBar later
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  // Get the instance of the Bluetooth
  FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  BluetoothConnection connection;

  int _deviceState;

  bool isDisconnecting = false;

  int st = 0;

  String currentDeviceName, currentDeviceAddress;

  Map<String, Color> colors = {
    'onBorderColor': Colors.blue,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.blue[700],
    'offTextColor': Colors.red[700],
    'neutralTextColor': Colors.black,
  };

  // To track whether the device is still connected to Bluetooth
  bool get isConnected => connection != null && connection.isConnected;

  // Define some variables, which will be required later
  List<BluetoothDevice> _devicesList = [];
  BluetoothDevice _device;
  bool _connected = false;
  bool _isButtonUnavailable = false;
  SetconStorage setconstorage = new SetconStorage();

  @override
  void initState() {
    super.initState();
    instance = widget.state;

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) {
      setState(() {
        _bluetoothState = state;
      });
    });
    _deviceState = 0; // neutral
    enableBluetooth();
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        getPairedDevices();
      });
    });
    if (MyApp.device != null){
      connection = MyApp.connection;
      _device = MyApp.device;
      autoconnect();
      _connected = true;
    }
  }

  @override
  void dispose() {
    // Avoid memory leak and disconnect
    // if (isConnected) {
    //   isDisconnecting = true;
    //   connection.dispose();
    //   connection = null;
    // }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return true;
    } else {
      await getPairedDevices();
    }
    return false;
  }

  // For retrieving and storing the paired devices
  // in a list.
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true.
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  // Now, its time to build the UI
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Setting"),
          //backgroundColor: Colors.blue[600],
          backgroundColor: Color.fromARGB(255, 2, 156, 225),
          actions: <Widget>[
            FlatButton.icon(
              icon: Icon(
                Icons.refresh,
                color: Colors.white,
              ),
              label: Text(
                "Refresh",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              splashColor: Colors.deepPurple,
              onPressed: () async {
                await getPairedDevices().then((_) {
                  show('Device list refreshed');
                });
              },
            ),
            Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/');
                  },
                  child: Icon(
                    Icons.home,
                    size: 26.0,
                  ),
                )),
          ],
        ),
        body: Container(
          color: Color.fromARGB(255, 2, 156, 225),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Visibility(
                visible: _isButtonUnavailable &&
                    _bluetoothState == BluetoothState.STATE_ON,
                child: LinearProgressIndicator(
                  backgroundColor: Colors.yellow,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        'Enable Bluetooth',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                            MyApp.connection = null;
                            MyApp.device = null;
                          }

                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
              ),
              Stack(
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Text(
                        "Device",
                        style: TextStyle(fontSize: 20, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                      /*Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          "Device",
                          style: TextStyle(fontSize: 24, color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                      ),*/
                      DropdownButton(
                        items: _getDeviceItems(),
                        onChanged: (value) => setState(() => _device = value),
                        value: _devicesList.isNotEmpty
                            ? _device
                            : null,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            /*Text(
                              'Device:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),*/
                            /*DropdownButton(
                              items: _getDeviceItems(),
                              onChanged: (value) =>
                                  setState(() => _device = value),
                              value: _devicesList.isNotEmpty ? _device : null,
                            ),*/
                            /*RaisedButton(
                              onPressed: _isButtonUnavailable
                                  ? null
                                  : _connected ? _disconnect : _connect,
                              child:
                                  Text(_connected ? 'Disconnect' : 'Connect'),
                            ),*/
                          ],
                        ),
                      ),
                      RaisedButton(
                        onPressed: _isButtonUnavailable
                            ? null
                            : _connected
                            ? disconnectAndDelete
                            : _connect,
                        child: Text(_connected ? 'Disconnect' : 'Connect'),
                      ),
                      Image(
                        image: AssetImage("images/atas.png"),
                        fit: BoxFit.fill,
                        width: 800,
                        height: 168,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            side: new BorderSide(
                              color: _deviceState == 0
                                  ? colors['neutralBorderColor']
                                  : _deviceState == 1
                                  ? colors['onBorderColor']
                                  : colors['offBorderColor'],
                              width: 3,
                            ),
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                          elevation: _deviceState == 0 ? 4 : 0,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Text(
                                    "TEST DEVICES",
                                    style: TextStyle(
                                      fontSize: 20,
                                      color: _deviceState == 0
                                          ? colors['neutralTextColor']
                                          : _deviceState == 1
                                          ? colors['onTextColor']
                                          : colors['offTextColor'],
                                    ),
                                  ),
                                ),
                                FlatButton(
                                  onPressed: _connected
                                      ? sendOnMessageToBluetooth
                                      : null,
                                  child: Text("TEST"),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Container(
                    color: Colors.blue,
                  ),
                ],
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        /*Text(
                          "NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),*/
                        //SizedBox(height: 15),
                        /*RaisedButton(
                          elevation: 2,
                          child: Text("Bluetooth Settings"),
                          onPressed: () {
                            FlutterBluetoothSerial.instance.openSettings();
                          },
                        ),*/
                        new Container(
                            color: Colors.white,
                            alignment: Alignment.center,
                            child: new Text(
                              "Suhu : $suhu",
                              style:
                              TextStyle(color: Colors.black, fontSize: 36),
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        /*floatingActionButton: FloatingActionButton(
          child: Icon(Icons.home),
          onPressed: () {
            Navigator.pushNamed(context, '/');
          },
        ),*/
      ),
    );
  }

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(DropdownMenuItem(
        child: Text('NONE'),
      ));
    } else {
      _devicesList.forEach((device) {
        items.add(DropdownMenuItem(
          child: Text(device.name),
          value: device,
        ));
      });
    }
    return items;
  }

  /*void diskonek() async {
    await connection.close();
  }

  void konek() async {
    await BluetoothConnection.toAddress("HC-05").then((_connection) {
      print('Connected to the device');
      connection.input.listen(_onDataReceived).onDone(() {
        if (isDisconnecting) {
          print('Disconnecting locally!');
        } else {
          print('Disconnected remotely!');
        }
      });
    }).catchError((error) {
      print('Cannot connect, exception occurred');
      print(error);
    });
    setState(() => _isButtonUnavailable = false);
  }*/

  // Method to connect to bluetooth
  void _connect() async {
    String str = '{suhu=37.5,mask=1,sound=1}';
    setconstorage.write(str);
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      show('No device selected');
    } else {
      if (!isConnected) {
        await BluetoothConnection.toAddress(_device.address)
        //await BluetoothConnection.toAddress("HC-05")
            .then((_connection) {
          print('Connected to the device');
          show('Connected to the device');
          MyApp.device = _device;
          MyApp.connection = _connection;
          connection = _connection;
          setState(() {
            _connected = true;
          });

          connection.input.listen(_onDataReceived).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locally!');
            } else {
              print('Disconnected remotely!');
            }
            if (this.mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occurred');
          print(error);
        });
//        show('Device connected');

        setState(() => _isButtonUnavailable = false);
      }
    }
  }

  List<String> messages = List<String>();
  String _messageBuffer = '';
  String jsonMessage = '';
  String suhu = '0.00';
  String jarak = '0';
  int warna = 0;

  void _onDataReceived(Uint8List data) {
    // Allocate buffer for parsed data
    int backspacesCounter = 0;
    data.forEach((byte) {
      if (byte == 8 || byte == 127) {
        backspacesCounter++;
      }
    });
    Uint8List buffer = Uint8List(data.length - backspacesCounter);
    int bufferIndex = buffer.length;

    // Apply backspace control character
    backspacesCounter = 0;
    for (int i = data.length - 1; i >= 0; i--) {
      if (data[i] == 8 || data[i] == 127) {
        backspacesCounter++;
      } else {
        if (backspacesCounter > 0) {
          backspacesCounter--;
        } else {
          buffer[--bufferIndex] = data[i];
        }
      }
    }

    // Create message if there is new line character
    String dataString = String.fromCharCodes(buffer);
    int index = buffer.indexOf(13);
    if (~index != 0) {
      setState(() {
        messages.clear();
        messages.add(
          backspacesCounter > 0
              ? _messageBuffer.substring(
              0, _messageBuffer.length - backspacesCounter)
              : _messageBuffer + dataString.substring(0, index),
        );
        _messageBuffer = dataString.substring(index);

        if (messages.length > 0) {
          jsonMessage = messages.last;
          print("Arduino Message: $jsonMessage");
          int index1 = jsonMessage.indexOf("Suhu");
          int index2 = jsonMessage.indexOf("}");
          suhu = jsonMessage.substring(index1 + 5, index2);
          index1 = jsonMessage.indexOf("Jarak");
          index2 = jsonMessage.indexOf(",");
          jarak = jsonMessage.substring(index1 + 6, index2);
          double doubleSuhu = double.parse(suhu);
          if (doubleSuhu > 37.5) {
            warna = 1;
          } else {
            warna = 0;
          }
          //show(jsonMessage);
        }
      });
    } else {
      _messageBuffer = (backspacesCounter > 0
          ? _messageBuffer.substring(
          0, _messageBuffer.length - backspacesCounter)
          : _messageBuffer + dataString);
    }
  }

  String bacaSuhu(String str) {
    int index = str.indexOf("Suhu");
    String xsuhu = str.substring(index + 5, str.length - 2);
    return xsuhu;
  }

  int bacaWarna(String str) {
    int index = str.indexOf("Suhu");
    String xsuhu = str.substring(index + 5, str.length - 2);
    double doubleSuhu = double.parse(xsuhu);
    if (doubleSuhu > 37.5) {
      warna = 1;
    } else {
      warna = 0;
    }
    return warna;
  }

  // Method to disconnect bluetooth
  void _disconnect() async {
    setState(() {
      _isButtonUnavailable = true;
      _deviceState = 0;
    });

    await connection.close();
    show('Device disconnected');
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  void disconnectAndDelete(){
    MyApp.connection = null;
    MyApp.device = null;
    _disconnect();
  }

  void autoconnect() {
    _disconnect();
    Timer(Duration(milliseconds: 50), () {
      _connect();
    });
  }

  // Method to send message,
  // for turning the Bluetooth device on
  /// tanggal 18 agustus 2020
  void sendOnMessageToBluetooth() async {
    connection.output.add(utf8.encode("1" + "\r\n"));
    await connection.output.allSent;
    //show('Device Turned On');
    setState(() {
      _deviceState = 1; // device on
    });
  }

  // Method to show a Snackbar,
  // taking message as the text
  Future show(
      String message, {
        Duration duration: const Duration(seconds: 2),
      }) async {
    await new Future.delayed(new Duration(milliseconds: 100));
    _scaffoldKey.currentState.showSnackBar(
      new SnackBar(
        content: new Text(
          message,
        ),
        duration: duration,
      ),
    );
  }
}
