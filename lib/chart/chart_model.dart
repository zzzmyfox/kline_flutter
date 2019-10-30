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
}