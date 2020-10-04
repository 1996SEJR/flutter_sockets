import 'dart:async';

import 'package:band_names/pages/take_picture_notifier.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class TakePicturePage extends StatefulWidget {
  const TakePicturePage({Key key}) : super(key: key);

  @override
  _TakePicturePageState createState() => _TakePicturePageState();
}

class _TakePicturePageState extends State<TakePicturePage> with WidgetsBindingObserver, SingleTickerProviderStateMixin {
  CameraDescription firstCamera;
  CameraController controller;
  TakePictureNotifier takePictureNotifier = TakePictureNotifier();

  double topPadding;
  double widthScreen;
  double heightScreen;

  double heigthContainerCamera;
  double heightBlackContainer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller?.dispose();
    super.dispose();
  }

  Future<void> _getCamera() async {
    availableCameras().then((List<CameraDescription> availableCameras) {
      firstCamera = availableCameras.first;
      _initializeCamera();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      controller?.dispose();
      return;
    }
    if (state == AppLifecycleState.resumed) {
      if (controller != null) {
        _initializeCamera();
      }
    }
  }

  Future<void> _initializeCamera() async {
    if (controller != null) {
      await controller.dispose();
    }

    controller = CameraController(firstCamera, ResolutionPreset.max);
    takePictureNotifier.initializeControllerFuture = controller.initialize();
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    topPadding = MediaQuery.of(context).padding.top * 2;
    widthScreen = size.width;
    heightScreen = size.height;

    final double heigthHalf = (heightScreen - topPadding) / 2;
    heightBlackContainer = heigthHalf - widthScreen / 2;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
      ),
      child: AnimatedBuilder(
        animation: takePictureNotifier,
        builder: (BuildContext context, Widget child) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: SafeArea(child: _buildBody(context)),
          );
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final Widget containerTop = _createContainerTop(context);
    final Widget containerBottom = _createContainerBottom(context);

    if (takePictureNotifier.isCameraGranted == null) {
      return CircularProgressIndicator();
    }

    return FutureBuilder<void>(
      future: takePictureNotifier.initializeControllerFuture,
      builder: (BuildContext context, AsyncSnapshot<dynamic> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return Container(
            child: Column(
              children: <Widget>[
                containerTop,
                _buildCamera(context),
                containerBottom,
              ],
            ),
          );
        } else {
          return CircularProgressIndicator();
        }
      },
    );
  }

  Widget _createContainerTop(BuildContext context) {
    return Container(
      child: Container(
        color: Colors.black,
        width: widthScreen,
        height: heightBlackContainer,
        padding: EdgeInsets.only(bottom: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Expanded(
                  child: IconButton(
                    alignment: Alignment.centerLeft,
                    icon: Icon(
                      Icons.timelapse_outlined,
                      color: Colors.white,
                      size: 12,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Expanded(
                  child: Text(
                    'Larvia',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                    ),
                  ),
                ),
                Expanded(
                  child: IconButton(
                    alignment: Alignment.centerRight,
                    icon: Icon(
                      Icons.question_answer,
                      color: Colors.white,
                      size: 15,
                    ),
                    onPressed: null,
                  ),
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 50),
              child: Text(
                'hola',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 10, color: Colors.white, height: 1.25),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _createContainerBottom(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        color: Colors.black,
        width: widthScreen,
        height: heightBlackContainer,
        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Expanded(
              child: Align(
                alignment: Alignment.center,
                child: FlatButton(
                  padding: EdgeInsets.zero,
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'cancel',
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Builder(
                builder: (BuildContext context) => IconButton(
                  icon: Icon(Icons.camera),
                  color: Colors.white,
                  onPressed: () => !takePictureNotifier.isPlaying ? capturePicture(context) : null,
                ),
              ),
            ),
            Expanded(child: Container())
          ],
        ),
      ),
    );
  }

  Widget _buildCamera(BuildContext context) {
    heigthContainerCamera = widthScreen / controller.value.aspectRatio;

    return Container(
      width: widthScreen,
      height: widthScreen,
      child: ClipRect(
        child: OverflowBox(
          alignment: Alignment.center,
          child: FittedBox(
            fit: BoxFit.fitWidth,
            child: Container(
              width: widthScreen,
              height: heigthContainerCamera,
              child: CameraPreview(controller),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> capturePicture(BuildContext context) async {
    takePictureNotifier.isPlaying = true;
    takePictureNotifier.smallRadius = 0.39;

    final String path = join(
      (await getTemporaryDirectory()).path,
      '${timestamp()}.jpg',
    );

    await controller.takePicture(path);
    takePictureNotifier.isPlaying = false;
  }

  String timestamp() => DateTime.now().millisecondsSinceEpoch.toString();

/*   Future<File> processImage(File file) async {
    final ImageProperties imageProperties = await FlutterNativeImage.getImageProperties(file.path);
    File croppedImage;

    final double aspectRatio = controller.value.aspectRatio;
    int width = imageProperties.width;
    int height = imageProperties.height;
    final List<int> centerOfImage = [width ~/ 2, height ~/ 2];

    final bool isWidthGreaterThanHeight = width > height;
    if (isWidthGreaterThanHeight) {
      width = imageProperties.height;
      height = imageProperties.width;
    }

    final int newWidth = (height * aspectRatio).floor();
    final int pointX = centerOfImage[0] - newWidth ~/ 2;
    final int pointY = centerOfImage[1] - newWidth ~/ 2;

    croppedImage = await FlutterNativeImage.cropImage(
      file.path,
      pointX,
      pointY,
      newWidth,
      newWidth,
    );

    final File compressImage = await FlutterNativeImage.compressImage(croppedImage.path, quality: 100, percentage: 100);
    final String imagePath = await getPathDirectory();
    return File('$imagePath/${timestamp()}.jpg')..writeAsBytesSync(compressImage.readAsBytesSync());
  } */
}
