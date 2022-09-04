import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ResultScan extends StatefulWidget {
  const ResultScan({key, this.data}) : super(key: key);

  final String data;

  @override
  _ResultScanState createState() => _ResultScanState();
}

class _ResultScanState extends State<ResultScan> {
  TextEditingController _dataController;

  @override
  void initState() {
    super.initState();
    _dataController = TextEditingController();
    _dataController.text = widget.data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Result"),
      ),
      body: Center(
        child: Container(
          margin: EdgeInsets.all(12),
          padding: EdgeInsets.symmetric(vertical: 12),
          child: TextFormField(
            cursorColor: Colors.black,
            style: GoogleFonts.openSans(fontSize: 12),
            keyboardType: TextInputType.text,
            controller: _dataController,
            decoration: new InputDecoration(
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide:
                        BorderSide(color: Color(0xFF000000).withOpacity(0.15))),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Color(0xFF1F3A93))),
                filled: false,
                contentPadding: EdgeInsets.only(left: 24.0, right: 24.0),
                hintStyle: GoogleFonts.openSans(
                    fontSize: 12, color: Color(0xFF000000).withOpacity(0.15)),
                hintText: "Input Data",
                errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Colors.red)),
                focusedErrorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(16)),
                    borderSide: BorderSide(color: Colors.red, width: 1)),
                errorStyle: GoogleFonts.openSans(fontSize: 10)),
            obscureText: false,
            validator: (value) {
              if (value.isEmpty) {
                return "Field is required";
              }
              return null;
            },
            onSaved: (value) {},
          ),
        ),
      ),
    );
  }
}
