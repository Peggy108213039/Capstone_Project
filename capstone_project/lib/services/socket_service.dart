import 'package:web_socket_channel/web_socket_channel.dart';

void main(List<String> arguments) {
  /// Create the WebSocket channel
  final channel = WebSocketChannel.connect(
    Uri.parse('http://127.0.0.1:3000/'),
  );

  channel.sink.add(
    'received',
    // jsonEncode(
    //   {
    //     "type": "subscribe",
    //     "channels": [
    //       {
    //         "name": "ticker",
    //         "product_ids": [
    //           "BTC-EUR",
    //         ]
    //       }
    //     ]
    //   },
    // ),
  );

  /// Listen for all incoming data
  channel.stream.listen(
    (data) {
      print(data);
    },
    onError: (error) => print(error),
  );

}