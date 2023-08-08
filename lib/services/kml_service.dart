import 'package:capstone_project/models/map/user_location.dart';
import 'package:xml/xml.dart';

class KMLService {
  // 抓 kml 檔案中的座標
  static List<UserLocation> getGPSList({required String content}) {
    // 把 kml 檔案中的 gps 定位座標存入 locationList 中
    List<UserLocation> locationList = [];
    final xmlGpx = XmlDocument.parse(content);
    // print('內容  ${xmlGpx.toXmlString(pretty: true, indent: '\t')}');

    // 抓檔案中 <coordinates> tag 中經緯度的值
    final coordinates = xmlGpx.findAllElements('coordinates');
    coordinates.map((node) {
      return node;
    }).forEach((XmlElement element) {
      String result = element.text;
      List<String> pointList = result.split(' ');
      // print('pointList $pointList');
      for (int i = 0; i < pointList.length; i++) {
        List<String> point = pointList[i].split(',');
        if (point.length == 3) {
          UserLocation userLocation = UserLocation(
              longitude: double.parse(point[0]),
              latitude: double.parse(point[1]),
              altitude: double.parse(point[2]),
              currentTime: UserLocation.getCurrentTime());
          locationList.add(userLocation);
        }
      }
    });
    // print('locationList $locationList');
    return locationList;
  }
}
