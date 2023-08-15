import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:web_socket_channel/io.dart';
import 'package:video_player/video_player.dart';

class MediaProjectionScreen extends StatefulWidget {
  const MediaProjectionScreen({Key? key}) : super(key: key);

  @override
  _MediaProjectionScreenState createState() => _MediaProjectionScreenState();
}

class _MediaProjectionScreenState extends State<MediaProjectionScreen> {
  final channel = IOWebSocketChannel.connect('ws://192.168.0.28:8080');

  Uint8List? _mediaData;
  String? _mediaType;
  VideoPlayerController? _videoPlayerController;

  @override
  void initState() {
    super.initState();
    channel.stream.listen((data) {
      dynamic decodedData = json.decode(data);
      setState(() {
        _mediaType = decodedData['type'];
        _mediaData = base64Decode(decodedData['data']);

        if (_mediaType == 'video') {
          _playVideo();
        } else if (_mediaType == 'image') {
          _showImage();
        }
      });
    });
  }

  void _playVideo() async {
    _videoPlayerController?.dispose(); // Libera el controlador de video anterior si existe

    // Crea un nuevo archivo temporal para guardar el video
    final tempDir = await getTemporaryDirectory();
    final tempVideoPath = '${tempDir.path}/temp_video.mp4';
    File(tempVideoPath).writeAsBytesSync(_mediaData!);

    // Crea un nuevo controlador de video desde el archivo temporal
    _videoPlayerController = VideoPlayerController.file(File(tempVideoPath));

    _videoPlayerController!.initialize().then((_) {
      _videoPlayerController!.play();
    });
  }

  void _showImage() {
    _videoPlayerController?.pause(); // Pausa la reproducción de video si está reproduciendo

    // No es necesario guardar imágenes temporalmente, se pueden mostrar directamente
  }

  @override
  void dispose() {
    channel.sink.close();
    _videoPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proyección de Medios'),
      ),
      body: Center(
        child: _mediaData != null
            ? _mediaType == 'video'
                ? AspectRatio(
                    aspectRatio: _videoPlayerController!.value.aspectRatio,
                    child: VideoPlayer(_videoPlayerController!),
                  )
                : _mediaType == 'image'
                    ? Image.memory(_mediaData!)
                    : const Text('Tipo de medio no admitido')
            : const Text('No se ha proyectado ningún medio'),
      ),
    );
  }
}
