
import 'package:flutter/material.dart';

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {

  double close;
  double open;
  Color up = Color(0xFF03ad8f);
  Color down = Color(0xFFff524a);
  Color text = Color(0xFF6d88a5);
  Color value = Color(0xFFd4d7eb);
  bool isUp = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: 130.0,
      color: Color(0xFF131e30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Container(
            margin: EdgeInsets.only(left: 15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(top: 28.0),
                  child: Text(
                    "3926.50",
                    style: TextStyle(color: up, fontSize: 30.0, fontWeight: FontWeight.bold),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 11.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        child: Text("≈26660.45 CNY", style: textStyle(),),
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 11.0),
                        child: Text("+12.52%", style: textStyle(color: up)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 28.0),
            child: Row(
              children: <Widget>[
                Container(
                  margin: EdgeInsets.only(right: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                          child: Text("高", textAlign: TextAlign.center,style: textStyle(),)),
                      Container(
                          margin: EdgeInsets.only(top: 18),
                          child: Text("收",textAlign: TextAlign.center, style: textStyle(),)),
                      Container(
                          margin: EdgeInsets.only(top: 18),
                          child: Text("24H", textAlign: TextAlign.center,style: textStyle(),)),
                    ],
                  ),
                ),
                Container(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Container(child: Text("72521.16", style: textStyle(color: value))),
                      Container(
                        margin: EdgeInsets.only(top: 18),
                          child: Text("0.003215", textAlign: TextAlign.center, style: textStyle(color: value))),
                      Container(
                          margin: EdgeInsets.only(top: 18),
                          child: Text("610143627", textAlign: TextAlign.center, style: textStyle(color: value))),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
 TextStyle textStyle({Color color, double fontSize, FontWeight fontWeight}) {
  return TextStyle(
    color: color ?? Color(0xFF6d88a5),
    fontSize: fontSize ?? 12.0,
    fontWeight: fontWeight ?? FontWeight.normal
  );
}

