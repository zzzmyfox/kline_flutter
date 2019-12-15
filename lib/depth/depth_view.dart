import 'package:flutter/material.dart';

import 'depth_model.dart';
import 'depth_painter.dart';

class DepthView extends StatefulWidget {
   DepthView(
     this.bidsList,
     this.asksList
  );
  final List<DepthModel> bidsList;
  final List<DepthModel> asksList;
  @override
  _DepthViewState createState() => _DepthViewState();
}

class _DepthViewState extends State<DepthView> {
  List<DepthModel> _buyDataList = List();
  List<DepthModel>  _sellDataList = List();

  @override
  void didUpdateWidget(DepthView oldWidget) {
    super.didUpdateWidget(oldWidget);
    setState(() {
        setBuyDataList(widget.bidsList);
        setSellDataList(widget.asksList);
    });
  }
  void setBuyDataList(List<DepthModel> bidsList) {
    _buyDataList.clear();
    _buyDataList.addAll(bidsList);
    _buyDataList.sort();
    for (int i = _buyDataList.length - 1; i >= 0; i--) {
        if (i < _buyDataList.length - 1) {
            _buyDataList[i].setVolume(_buyDataList[i].volume + _buyDataList[i + 1].volume);
        }
    }
  }
  void setSellDataList(List<DepthModel> asksList) {
    _sellDataList.clear();
    _sellDataList.addAll(asksList);
    _sellDataList.sort();
    for (int i = 0; i < _sellDataList.length; i++) {
        if (i > 0) {
            _sellDataList[i].setVolume(_sellDataList[i].volume + _sellDataList[i - 1].volume);
        }
    }
  }
  CustomPaint depthView() {
    return CustomPaint(painter: DepthPainter(buyDataList:_buyDataList, sellDataList: _sellDataList));
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Color(0xFF131e30),
        height: 200,
        width: MediaQuery.of(context).size.width,
        child: depthView(),
    );
  }
}
