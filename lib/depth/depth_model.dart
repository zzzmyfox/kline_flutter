class DepthModel implements Comparable<DepthModel> {
  double price;
  double volume;
  int tradeType;
  double x;
  double y;

  DepthModel(double price, double volume) {
    this.price = price;
    this.volume = volume;
  }

  void setPrice(double price) {this.price = price;}
  void setVolume(double volume) {this.volume = volume;}
  void setX(double x) {this.x = x;}
  void setY(double y) {this.y = y;}

  @override
  int compareTo(DepthModel other) {
    // TODO: implement compareTo
    double diff = this.price - other.price;
    if (diff > 0) {
      return 1;
    } else if (diff < 0) {
      return - 1;
    } else {
      return 0;
    }
  }
}