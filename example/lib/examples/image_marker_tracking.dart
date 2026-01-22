import 'package:ar_flutter_plugin_plus/datatypes/config_planedetection.dart';
import 'package:ar_flutter_plugin_plus/datatypes/node_types.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_anchor_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_location_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_object_manager.dart';
import 'package:ar_flutter_plugin_plus/managers/ar_session_manager.dart';
import 'package:ar_flutter_plugin_plus/models/ar_anchor.dart';
import 'package:ar_flutter_plugin_plus/models/ar_node.dart';
import 'package:ar_flutter_plugin_plus/widgets/ar_view.dart';
import 'package:flutter/material.dart';
import 'package:vector_math/vector_math_64.dart';

class ImageMarkerTracking extends StatefulWidget {
  const ImageMarkerTracking({Key? key}) : super(key: key);

  @override
  State<ImageMarkerTracking> createState() => _ImageMarkerTrackingState();
}

class _ImageMarkerTrackingState extends State<ImageMarkerTracking> {
  ARSessionManager? arSessionManager;
  ARObjectManager? arObjectManager;
  ARAnchorManager? arAnchorManager;
  ARLocationManager? arLocationManager;

  ARAnchor? anchor;
  ARNode? node;

  void onARViewCreated(
      ARSessionManager arSessionManager,
      ARObjectManager arObjectManager,
      ARAnchorManager arAnchorManager,
      ARLocationManager arLocationManager) {
    this.arSessionManager = arSessionManager;
    this.arObjectManager = arObjectManager;
    this.arAnchorManager = arAnchorManager;
    this.arLocationManager = arLocationManager;

    this.arSessionManager!.onInitialize(
          showFeaturePoints: false,
          showPlanes: false,
          customPlaneTexturePath: "Images/triangle.png",
          showWorldOrigin: false,
          handleTaps: false,
          trackingImagePaths: [
            "Images/augmented-images-earth.jpg",
          ],
          continuousImageTracking: false,
          imageTrackingUpdateIntervalMs: 100,
        );
    this.arObjectManager!.onInitialize();
    this.arSessionManager!.onImageDetected = onImageDetected;
  }

  void onImageDetected(String imageName, Matrix4 transformation) {
    placeObjectOnImage(imageName, transformation);
  }

  Future<void> placeObjectOnImage(
      String imageName, Matrix4 transformation) async {
    try {
      var modelUrl = "Models/Chicken_01/Chicken_01.gltf";

      double scale = 0.005;
      final modelTransform = Matrix4.fromFloat64List(transformation.storage);
      modelTransform.translate(0.0, 0.0, 0.02);
      modelTransform.scale(scale, scale, scale);

      if (node == null) {
        var imageNode = ARNode(
          type: NodeType.localGLTF2,
          uri: modelUrl,
          transformation: modelTransform,
        );

        bool? didAddNode = await arObjectManager!.addNode(imageNode);
        if (didAddNode == true) {
          node = imageNode;
        } else {
          //arSessionManager!.onError("Adding Node failed");
        }
      } else {
        node!.transform = modelTransform;
      }
    } catch (e) {
      print("Error placing object on image: $e");
    }
  }

  @override
  void dispose() {
    if (node != null) {
      arObjectManager?.removeNode(node!);
      node = null;
    }
    if (anchor != null) {
      arAnchorManager?.removeAnchor(anchor!);
      anchor = null;
    }
    super.dispose();
    arSessionManager!.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Marker Tracking'),
      ),
      body: ARView(
        onARViewCreated: onARViewCreated,
        planeDetectionConfig: PlaneDetectionConfig.horizontalAndVertical,
      ),
    );
  }
}
