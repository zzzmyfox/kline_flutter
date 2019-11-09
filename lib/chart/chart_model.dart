class ChartModel {
  int timestamp;
  double closePrice;
  double openPrice;
  double maxPrice;
  double minPrice;
  double volume;
  ///kline data
  ChartModel(int timestamp, double openPrice, double closePrice, double maxPrice, double minPrice, double volume) {
    this.timestamp = timestamp;
    this.openPrice = openPrice;
    this.closePrice = closePrice;
    this.maxPrice = maxPrice;
    this.minPrice = minPrice;
    this.volume = volume;
  }
  ///Main chart view
  double leftStartX;
  double rightEndX;
  double closeY;
  double openY;
  void setLeftStartX(double leftStartX) {
    this.leftStartX = leftStartX;
  }
  void setRightEndX(double rightEndX) {
    this.rightEndX = rightEndX;
  }
  void setCloseY(double closeY) {
    this.closeY = closeY;
  }
  void setOpenY(double openY) {
    this.openY = openY;
  }
  ///MA
  double priceMA5;
  double priceMA10;
  double priceMA30;
  double volumeMA5;
  double volumeMA10;
  // price MA
  void setPriceMA5(double priceMA5) {
    this.priceMA5 = priceMA5;
  }
  void setPriceMA10(double priceMA10) {
    this.priceMA10 = priceMA10;
  }
  void setPriceMA30(double priceMA30) {
    this.priceMA30 = priceMA30;
  }
  // volume ma
  void setVolumeMA5(double volumeMA5) {
    this.volumeMA5 = volumeMA5;
  }
  void setVolumeMA10(double volumeMA10) {
    this.volumeMA10 = volumeMA10;
  }
  /// BOLL

}