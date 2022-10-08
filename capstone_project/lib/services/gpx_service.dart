import 'dart:math';

import 'package:capstone_project/models/map/user_location.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:map_elevation/map_elevation.dart';
import 'package:xml/xml.dart';

class GPXService {
  // 抓出 result 中所有的 gps 座標
  static Map<String, dynamic> getGPSList({required String content}) {
    // 把 gpx 檔案中的 gps 定位座標存入 points (list) 中，並回傳 points
    List<LatLng> points = [];
    List<ElevationPoint> elePoints = [];
    final xmlGpx = XmlDocument.parse(content);
    // print('內容  ${xmlGpx.toXmlString(pretty: true, indent: '\t')}');

    // 抓檔案中 <trkpt> tag 中經緯度的值
    final trkpts = xmlGpx.findAllElements('trkpt');
    trkpts.map((node) {
      return node;
    }).forEach((XmlElement element) {
      var lat = element.getAttribute('lat');
      var lon = element.getAttribute('lon');
      var ele = element.findElements('ele').single.text;
      if (lat != null && lon != null) {
        LatLng p = LatLng(double.parse(lat), double.parse(lon));
        ElevationPoint eleP = ElevationPoint(
            double.parse(lat), double.parse(lon), double.parse(ele));
        points.add(p);
        elePoints.add(eleP);
      }
    });
    return {
      'latLngList': points,
      'elevationPointList': elePoints,
    };
  }

  static void _buildTrkpt(
      {required XmlBuilder builder,
      required double latitude,
      required double longitude,
      required double altitude,
      required String currentTime}) {
    builder.element('trkpt', nest: () {
      builder.attribute('lat', latitude);
      builder.attribute('lon', longitude);
      builder.element('ele', nest: altitude);
      builder.element('time', nest: currentTime);
    });
  }

  // 寫 gpx 檔案內容
  static String writeGPX(
      {required String trackName,
      required String time,
      required List<UserLocation> userLocationList}) {
    final builder = XmlBuilder();
    builder.processing('xml', 'version="1.0" encoding="UTF-8"');
    builder.element('gpx', nest: () {
      builder.attribute('version', '1.1');
      // FIXME testUser 改成使用者名稱
      builder.attribute('creator', 'testUser');
      builder.element('metadata', nest: () {
        builder.element('name', nest: trackName);
        builder.element('time', nest: time);
      });
      builder.element('trk', nest: () {
        builder.element('trkseg', nest: () {
          for (int i = 0; i < userLocationList.length; i++) {
            _buildTrkpt(
                builder: builder,
                latitude: userLocationList[i].latitude,
                longitude: userLocationList[i].longitude,
                altitude: userLocationList[i].altitude,
                currentTime: userLocationList[i].currentTime);
          }
        });
      });
    });
    final XmlDocument document = builder.buildDocument();
    print(document.toXmlString(pretty: true, indent: '\t'));
    return document.toXmlString(pretty: true, indent: '\t');
  }

  // 抓出 gpsList 中的界線
  static LatLngBounds getBounds({required List<LatLng> list}) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > (x1 ?? 0)) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > (y1 ?? 0)) y1 = latLng.longitude;
        if (latLng.longitude < (y0 ?? double.infinity)) y0 = latLng.longitude;
      }
    }
    LatLng northeast = LatLng(x1 ?? 0, y1 ?? 0);
    LatLng southwest = LatLng(x0 ?? 0, y0 ?? 0);

    return LatLngBounds(
      LatLng(x1 ?? 0, y1 ?? 0),
      LatLng(x0 ?? 0, y0 ?? 0),
    );
  }

  // 抓出 bounds 正中間的座標
  static LatLng getCenterLatLng({required LatLngBounds bounds}) {
    LatLng l1 = bounds.northWest;
    LatLng l2 = bounds.southEast;
    return LatLng(
        (l1.latitude + l2.latitude) / 2, (l1.longitude + l2.longitude) / 2);
  }

  // 抓 zoom level
  static double getZoomLevel(
      {required LatLngBounds bounds, required Size mapDimensions}) {
    var worldDimension = const Size(1024, 1024);

    var ne = bounds.northWest;
    var sw = bounds.southEast;

    var latFraction = (latRad(ne.latitude) - latRad(sw.latitude)) / pi;

    var lngDiff = ne.longitude - sw.longitude;
    var lngFraction = ((lngDiff < 0) ? (lngDiff + 360) : lngDiff) / 360;

    var latZoom =
        zoom(mapDimensions.height, worldDimension.height, latFraction);
    var lngZoom = zoom(mapDimensions.width, worldDimension.width, lngFraction);

    late double result;
    if (latZoom < 0) {
      result = lngZoom;
    } else if (lngZoom < 0) {
      result = latZoom;
    } else {
      result = (min(latZoom, lngZoom) + 1.6);
    }
    if (result > 18) {
      result = 18;
    }
    print('zoom result $result');
    // result -= 0.75;
    return result;
  }

  static double latRad(lat) {
    var sinValue = sin(lat * pi / 180);
    var radX2 = log((1 + sinValue) / (1 - sinValue)) / 2;
    return max(min(radX2, pi), -pi) / 2;
  }

  static double zoom(mapPx, worldPx, fraction) {
    return (log(mapPx / worldPx / fraction) / ln2).floorToDouble();
  }
}
