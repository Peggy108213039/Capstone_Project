class Track {
  final String tID;
  final String uID;
  final String track_name; // 軌跡名稱
  final String track_locate; // 軌跡檔案儲存路徑
  final String start; // 軌跡開始紀錄的時間
  final String finish; // 軌跡結束紀錄的時間
  final String total_distance; // 總距離
  final String time; // 軌跡上傳的日期
  final String track_type; // 軌跡類型 (在此 APP 中紀錄的 或 匯入進來的)
  // final String latLngList; // 軌跡 gps 的資料，LatLng 沒有高度
  // final String elevationPointList; // 軌跡 gps 的資料，Elevation 有高度

  Track({
    required this.tID,
    required this.uID,
    required this.track_name,
    required this.track_locate,
    required this.start,
    required this.finish,
    required this.total_distance,
    required this.time,
    required this.track_type,
    // required this.latLngList,
    // required this.elevationPointList
  });

  @override
  String toString() {
    return '''TrackModel{
      tID: $tID
      uID: $uID, 
      track_name: $track_name, 
      track_locate: $track_locate, 
      start: $start, 
      finish: $finish, 
      total_distance: $total_distance, 
      time: $time, 
      track_type: $track_type
      }''';
  }

  Map<String, dynamic> toMap() {
    return {
      'tID': tID,
      'uID': uID,
      'track_name': track_name,
      'track_locate': track_locate,
      'start': start,
      'finish': finish,
      'total_distance': total_distance,
      'time': time,
      'track_type': track_type
    };
  }
  // 呼叫的方式
  // data.toMap();
}

class TrackRequestModel {
  final String uID;
  final String track_name; // 軌跡名稱
  final String track_locate; // 軌跡檔案儲存路徑
  final String start; // 軌跡開始紀錄的時間
  final String finish; // 軌跡結束紀錄的時間
  final String total_distance; // 總距離
  final String time; // 軌跡上傳的日期
  final String track_type; // 軌跡類型 (在此 APP 中紀錄的 或 匯入進來的)
  // final String latLngList; // 軌跡 gps 的資料，LatLng 沒有高度
  // final String elevationPointList; // 軌跡 gps 的資料，Elevation 有高度

  TrackRequestModel({
    required this.uID,
    required this.track_name,
    required this.track_locate,
    required this.start,
    required this.finish,
    required this.total_distance,
    required this.time,
    required this.track_type,
    // required this.latLngList,
    // required this.elevationPointList
  });

  @override
  String toString() {
    return '''TrackModel{
      uID: $uID, 
      track_name: $track_name, 
      track_locate: $track_locate, 
      start: $start, 
      finish: $finish, 
      total_distance: $total_distance, 
      time: $time, 
      track_type: $track_type
      }''';
  }

  Map<String, dynamic> toMap() {
    return {
      'uID': uID,
      'track_name': track_name,
      'track_locate': track_locate,
      'start': start,
      'finish': finish,
      'total_distance': total_distance,
      'time': time,
      'track_type': track_type
    };
  }
  // 呼叫的方式
  // data.toMap();
}
