class Ride {
  final String date;
  final String driverId; // Add driverId
  final String driverName;
  final String startPoint;
  final String destinationPoint;
  final double price;

  Ride({
    required this.date,
    required this.driverId,
    required this.driverName,
    required this.startPoint,
    required this.destinationPoint,
    required this.price,
  });
}
