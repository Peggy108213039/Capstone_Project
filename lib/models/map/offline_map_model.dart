class OfflineMap {
  // final String offline_map_ID;
  final String uID;
  final String offline_map_name; // 離線地圖名稱
  final String centerLatitude;
  final String centerLongitude;
  final String southWestLatitude;
  final String southWestLongitude;
  final String northEastLatitude;
  final String northEastLongitude;
  final String png_dir_locate; // 解壓縮後的 png dir 儲存路徑

  OfflineMap(
      {
      // required this.offline_map_ID,
      required this.uID,
      required this.offline_map_name,
      required this.centerLatitude,
      required this.centerLongitude,
      required this.southWestLatitude,
      required this.southWestLongitude,
      required this.northEastLatitude,
      required this.northEastLongitude,
      required this.png_dir_locate});

  @override
  String toString() {
    return '''OfflineMap{
      uID: $uID, 
      offline_map_name: $offline_map_name, 
      centerLatitude: $centerLatitude,
      centerLongitude: $centerLongitude,
      southWestLatitude: $southWestLatitude,
      southWestLongitude: $southWestLongitude,
      northEastLatitude: $northEastLatitude,
      northEastLongitude: $northEastLongitude,
      png_dir_locate: $png_dir_locate
      }''';
  }

  Map<String, dynamic> toMap() {
    return {
      'uID': uID,
      'offline_map_name': offline_map_name,
      'centerLatitude': centerLatitude,
      'centerLongitude': centerLongitude,
      'southWestLatitude': southWestLatitude,
      'southWestLongitude': southWestLongitude,
      'northEastLatitude': northEastLatitude,
      'northEastLongitude': northEastLongitude,
      'png_dir_locate': png_dir_locate
    };
  }
  // 呼叫的方式
  // data.toMap();
}
