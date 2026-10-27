import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:webview_flutter/webview_flutter.dart';

/// Interactive 3D Avatar Viewer for Virtual Fashion Try-On.
/// Connects to the VirtualFashion schema (FashionIntegrationManager).
class Avatar3DViewer extends StatefulWidget {
  final String garmentColor;
  final String pantsColor;
  final String garmentType;
  final String garmentCategory;
  final String skinTone;
  final String gender;
  final VoidCallback? onResetCamera;

  const Avatar3DViewer({
    super.key,
    this.garmentColor = '#222225',
    this.pantsColor = '#2B2D31',
    this.garmentType = 'sweater',
    this.garmentCategory = 'top',
    this.skinTone = 'tan',
    this.gender = 'male',
    this.onResetCamera,
  });

  @override
  State<Avatar3DViewer> createState() => Avatar3DViewerState();
}

class Avatar3DViewerState extends State<Avatar3DViewer> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentCameraView = 'front';
  late String _currentSkinTone;
  bool _isAutoRotating = false;
  static final Map<String, String> _cachedModels = {};
  String? _avatarJson;

  @override
  void initState() {
    super.initState();
    _currentSkinTone = widget.skinTone;
    _initWebViewController();
  }

  Future<void> _initWebViewController() async {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFF7F3EE))
      ..addJavaScriptChannel(
        'AvatarFlutterBridge',
        onMessageReceived: (JavaScriptMessage message) {
          if (message.message == 'READY') {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
              // Send initial clothing & skin tone
              updateGarment(
                color: widget.garmentColor,
                pantsColor: widget.pantsColor,
                type: widget.garmentType,
                category: widget.garmentCategory,
              );
              setSkinTone(_currentSkinTone);
            }
          }
        },
      );

    final isFemale = widget.gender.toLowerCase().contains('fem') ||
        widget.gender == '2' ||
        widget.gender.toLowerCase().contains('wom');

    final modelKey = isFemale ? 'female' : 'male';
    final modelAsset = isFemale
        ? 'assets/models/female_avatar.json'
        : 'assets/models/real_avatar.json';

    if (_cachedModels.containsKey(modelKey)) {
      _avatarJson = _cachedModels[modelKey];
    } else {
      try {
        _avatarJson = await rootBundle.loadString(modelAsset);
        _cachedModels[modelKey] = _avatarJson!;
      } catch (e) {
        debugPrint('Error loading $modelAsset: $e');
      }
    }

    if (mounted) {
      _controller.loadHtmlString(_buildHtmlContent(
        avatarJsonData: _avatarJson ?? '{}',
        isFemale: isFemale,
        initialTopColor: widget.garmentColor,
        initialPantsColor: widget.pantsColor,
      ));
    }
  }

  @override
  void didUpdateWidget(covariant Avatar3DViewer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.gender != widget.gender) {
      _initWebViewController();
      return;
    }
    if (oldWidget.garmentColor != widget.garmentColor ||
        oldWidget.pantsColor != widget.pantsColor ||
        oldWidget.garmentType != widget.garmentType ||
        oldWidget.garmentCategory != widget.garmentCategory) {
      updateGarment(
        color: widget.garmentColor,
        pantsColor: widget.pantsColor,
        type: widget.garmentType,
        category: widget.garmentCategory,
      );
    }
    if (oldWidget.skinTone != widget.skinTone) {
      setSkinTone(widget.skinTone);
    }
  }

  /// Update garment color and attributes on the 3D Avatar
  void updateGarment({
    required String color,
    String? pantsColor,
    String type = 'sweater',
    String category = 'top',
  }) {
    final payload = jsonEncode({
      'messageType': 'clothing_scan',
      'clothing': {
        'category': category,
        'type': type,
        'color': color,
        if (pantsColor != null) 'pantsColor': pantsColor,
      }
    });

    _controller.runJavaScript(
      'if (window.handleFashionMessage) { window.handleFashionMessage($payload); }',
    );
  }

  /// Change Skin Tone ('fair', 'light', 'medium', 'tan', 'deep')
  void setSkinTone(String tone) {
    _currentSkinTone = tone;
    _controller.runJavaScript(
      'if (window.setSkinTone) { window.setSkinTone("$tone"); }',
    );
    if (mounted) setState(() {});
  }

  /// Change Camera Angle ('front', 'threeQuarter', 'side', 'back')
  void setCameraAngle(String angle) {
    _currentCameraView = angle;
    _controller.runJavaScript(
      'if (window.setCameraView) { window.setCameraView("$angle"); }',
    );
    if (mounted) setState(() {});
  }

  /// Toggle 360 Auto-Rotation
  void toggleAutoRotate() {
    _isAutoRotating = !_isAutoRotating;
    _controller.runJavaScript(
      'if (window.toggleAutoRotate) { window.toggleAutoRotate($_isAutoRotating); }',
    );
    if (mounted) setState(() {});
  }

  /// Reset view
  void resetView() {
    setCameraAngle('front');
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // ── 3D Canvas WebView ──
        ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: WebViewWidget(controller: _controller),
        ),

        // ── Loading Spinner ──
        if (_isLoading)
          Container(
            color: const Color(0xFFF7F3EE),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 36.w,
                    height: 36.w,
                    child: const CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Color(0xFFB5956A)),
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'Loading 3D Avatar...',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8A7E73),
                    ),
                  ),
                ],
              ),
            ),
          ),

        // ── Interactive Quick Controls (Angles & Rotation) ──
        if (!_isLoading) ...[
          // Top-right Angle & Auto-Rotate Pills
          Positioned(
            top: 10.h,
            right: 12.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 360 Spin button
                GestureDetector(
                  onTap: toggleAutoRotate,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _isAutoRotating
                          ? const Color(0xFFB5956A)
                          : Colors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(16.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sync_rounded,
                          size: 14.sp,
                          color: _isAutoRotating
                              ? Colors.white
                              : const Color(0xFF8A7E73),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '360°',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: _isAutoRotating
                                ? Colors.white
                                : const Color(0xFF262321),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: 8.h),

                // Angles Column
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.08),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      _buildAngleButton('front', 'Front'),
                      SizedBox(height: 4.h),
                      _buildAngleButton('threeQuarter', '3/4'),
                      SizedBox(height: 4.h),
                      _buildAngleButton('side', 'Side'),
                      SizedBox(height: 4.h),
                      _buildAngleButton('back', 'Back'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bottom-left: Realistic Skin Tone Swatches
          Positioned(
            bottom: 12.h,
            left: 12.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(20.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Skin: ',
                    style: TextStyle(
                      fontSize: 10.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF8A7E73),
                    ),
                  ),
                  _buildSkinToneDot('fair', const Color(0xFFF2D6C4)),
                  _buildSkinToneDot('light', const Color(0xFFE5BCA0)),
                  _buildSkinToneDot('medium', const Color(0xFFC58F68)),
                  _buildSkinToneDot('tan', const Color(0xFF9D6843)),
                  _buildSkinToneDot('deep', const Color(0xFF5C3621)),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAngleButton(String angleKey, String label) {
    final bool isSelected = _currentCameraView == angleKey;
    return GestureDetector(
      onTap: () => setCameraAngle(angleKey),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFB5956A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : const Color(0xFF8A7E73),
          ),
        ),
      ),
    );
  }

  Widget _buildSkinToneDot(String toneKey, Color color) {
    final bool isSelected = _currentSkinTone == toneKey;
    return GestureDetector(
      onTap: () => setSkinTone(toneKey),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 3.w),
        width: 16.w,
        height: 16.w,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(
            color: isSelected ? const Color(0xFFB5956A) : Colors.transparent,
            width: 2.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFB5956A).withValues(alpha: 0.4),
                    blurRadius: 4,
                  )
                ]
              : null,
        ),
      ),
    );
  }

  /// Self-contained 3D WebGL / Three.js Avatar Canvas
  static String _buildHtmlContent({
    required String avatarJsonData,
    required bool isFemale,
    required String initialTopColor,
    required String initialPantsColor,
  }) {
    return '''
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=no">
  <title>Virtual Fashion 3D Avatar</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body, html {
      width: 100%;
      height: 100%;
      overflow: hidden;
      background-color: #F7F3EE;
      touch-action: none;
      -webkit-user-select: none;
      user-select: none;
    }
    #canvas-container {
      width: 100%;
      height: 100%;
      position: absolute;
      top: 0;
      left: 0;
      overflow: hidden;
    }
    canvas {
      display: block;
      width: 100% !important;
      height: 100% !important;
    }
  </style>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/three.js/r128/three.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/three@0.128.0/examples/js/controls/OrbitControls.js"></script>
</head>
<body>
  <div id="canvas-container"></div>

  <script>
    const RAW_AVATAR_DATA = $avatarJsonData;
    const IS_FEMALE = ${isFemale ? 'true' : 'false'};
    const INITIAL_TOP_COLOR = "$initialTopColor";
    const INITIAL_PANTS_COLOR = "$initialPantsColor";

    let scene, camera, renderer, controls;
    let avatarGroup, tshirtMaterial, skinMaterial, pantsMaterial, shoesMaterial;
    let isAutoRotating = false;
    let clock = new THREE.Clock();

    const skinTones = {
      fair: 0xF2D6C4,
      light: 0xE5BCA0,
      medium: 0xC58F68,
      tan: 0x9D6843,
      deep: 0x5C3621
    };

    function init() {
      const container = document.getElementById('canvas-container');
      const width = container.clientWidth || window.innerWidth;
      const height = container.clientHeight || window.innerHeight;

      // ── Scene ──
      scene = new THREE.Scene();
      scene.background = new THREE.Color(0xF7F3EE);

      // ── Camera (Aspect Ratio & Clear Headroom Framing) ──
      camera = new THREE.PerspectiveCamera(35, width / height, 0.1, 100);
      camera.position.set(0.04, 1.32, 4.25);

      // ── Renderer ──
      renderer = new THREE.WebGLRenderer({ antialias: true, alpha: true, powerPreference: "high-performance" });
      renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
      renderer.setSize(width, height, true);
      renderer.shadowMap.enabled = true;
      renderer.shadowMap.type = THREE.PCFSoftShadowMap;
      renderer.toneMapping = THREE.ACESFilmicToneMapping;
      renderer.toneMappingExposure = 1.05;
      container.appendChild(renderer.domElement);

      // ── Controls ──
      controls = new THREE.OrbitControls(camera, renderer.domElement);
      controls.enableDamping = true;
      controls.dampingFactor = 0.08;
      controls.enablePan = false;
      controls.minDistance = 2.0;
      controls.maxDistance = 6.0;
      controls.minPolarAngle = Math.PI / 4;
      controls.maxPolarAngle = Math.PI / 1.85;
      controls.target.set(0.04, 1.05, 0);

      // ── Lighting ──
      setupLighting();

      // ── Avatar & Clothing ──
      buildAvatar();

      // ── Pedestal Podium ──
      setupPedestal();

      // ── Dynamic Aspect Ratio & Viewport Resizing ──
      window.addEventListener('resize', onWindowResize);
      if (window.ResizeObserver) {
        const ro = new ResizeObserver(() => {
          updateDimensions();
        });
        ro.observe(container);
        if (document.body) ro.observe(document.body);
      }

      // Handle delayed layout measurement from Flutter WebView
      setTimeout(updateDimensions, 50);
      setTimeout(updateDimensions, 150);
      setTimeout(updateDimensions, 350);

      // Notify Flutter that viewer is ready
      if (window.AvatarFlutterBridge) {
        window.AvatarFlutterBridge.postMessage('READY');
      }

      animate();
    }

    function setupLighting() {
      const ambientLight = new THREE.AmbientLight(0xfff5ea, 0.95);
      scene.add(ambientLight);

      const keyLight = new THREE.DirectionalLight(0xfffaec, 1.35);
      keyLight.position.set(2.0, 3.8, 3.5);
      keyLight.castShadow = true;
      keyLight.shadow.mapSize.width = 1024;
      keyLight.shadow.mapSize.height = 1024;
      keyLight.shadow.bias = -0.0008;
      scene.add(keyLight);

      // Dedicated Face Light for clear facial features and head visibility
      const faceLight = new THREE.DirectionalLight(0xfff4eb, 0.65);
      faceLight.position.set(0.04, 2.05, 2.5);
      scene.add(faceLight);

      const fillLight = new THREE.DirectionalLight(0xe8d5be, 0.65);
      fillLight.position.set(-3.2, 2.5, 2.2);
      scene.add(fillLight);

      const rimLight = new THREE.DirectionalLight(0x7ec8ff, 1.15);
      rimLight.position.set(1.5, 3.8, -3.5);
      scene.add(rimLight);

      const rimLightGold = new THREE.DirectionalLight(0xd4af37, 0.7);
      rimLightGold.position.set(-2.5, 3.0, -2.5);
      scene.add(rimLightGold);

      const spotLight = new THREE.SpotLight(0xfffaee, 0.8, 8, Math.PI / 4, 0.4);
      spotLight.position.set(0, 5.0, 0);
      spotLight.target.position.set(0, 0.2, 0);
      scene.add(spotLight);
      scene.add(spotLight.target);
    }

    function setupPedestal() {
      const podiumGroup = new THREE.Group();

      const stageGeo = new THREE.CylinderGeometry(1.05, 1.10, 0.08, 64);
      const stageMat = new THREE.MeshStandardMaterial({
        color: 0x1E2B3A,
        roughness: 0.38,
        metalness: 0.35
      });
      const stageMesh = new THREE.Mesh(stageGeo, stageMat);
      stageMesh.position.y = 0.04;
      stageMesh.receiveShadow = true;
      podiumGroup.add(stageMesh);

      const goldRingGeo = new THREE.TorusGeometry(1.05, 0.012, 16, 64);
      const goldMat = new THREE.MeshStandardMaterial({
        color: 0xC8A97E,
        roughness: 0.25,
        metalness: 0.85
      });
      const goldRingMesh = new THREE.Mesh(goldRingGeo, goldMat);
      goldRingMesh.rotation.x = Math.PI / 2;
      goldRingMesh.position.y = 0.08;
      podiumGroup.add(goldRingMesh);

      const planeGeo = new THREE.PlaneGeometry(3.2, 3.2);
      const shadowCanvas = document.createElement('canvas');
      shadowCanvas.width = 128;
      shadowCanvas.height = 128;
      const ctx = shadowCanvas.getContext('2d');
      const grad = ctx.createRadialGradient(64, 64, 20, 64, 64, 64);
      grad.addColorStop(0, 'rgba(20, 28, 38, 0.55)');
      grad.addColorStop(0.6, 'rgba(30, 40, 52, 0.20)');
      grad.addColorStop(1, 'rgba(247, 243, 238, 0)');
      ctx.fillStyle = grad;
      ctx.fillRect(0, 0, 128, 128);

      const shadowTex = new THREE.CanvasTexture(shadowCanvas);
      const planeMat = new THREE.MeshBasicMaterial({
        map: shadowTex,
        transparent: true,
        depthWrite: false
      });
      const shadowMesh = new THREE.Mesh(planeGeo, planeMat);
      shadowMesh.rotation.x = -Math.PI / 2;
      shadowMesh.position.y = 0.005;
      podiumGroup.add(shadowMesh);

      scene.add(podiumGroup);
    }

    function buildAvatar() {
      avatarGroup = new THREE.Group();

      // ── Materials ──
      skinMaterial = new THREE.MeshStandardMaterial({
        color: skinTones['medium'],
        roughness: 0.52,
        metalness: 0.05
      });

      tshirtMaterial = new THREE.MeshStandardMaterial({
        color: new THREE.Color(resolveColor(INITIAL_TOP_COLOR, '#222225')),
        roughness: 0.65,
        metalness: 0.05
      });

      pantsMaterial = new THREE.MeshStandardMaterial({
        color: new THREE.Color(resolveColor(INITIAL_PANTS_COLOR, '#2B2D31')),
        roughness: 0.70,
        metalness: 0.03
      });

      shoesMaterial = new THREE.MeshStandardMaterial({
        color: 0x1A1C20,
        roughness: 0.38,
        metalness: 0.10
      });

      const eyesMat = new THREE.MeshStandardMaterial({
        color: 0x243242,
        roughness: 0.15,
        metalness: 0.2
      });

      const detailsMat = new THREE.MeshStandardMaterial({
        color: 0xE8E8E8,
        roughness: 0.35,
        metalness: 0.1
      });

      const eyebrowsMat = new THREE.MeshStandardMaterial({
        color: 0x1A1412,
        roughness: 0.85,
        metalness: 0.02
      });

      const lashesMat = new THREE.MeshStandardMaterial({
        color: 0x111111,
        roughness: 0.9,
        metalness: 0.0
      });

      // ── Submesh Materials (Top Garment, Pants, Bare Feet, Skin & Features) ──
      const materials = [
        tshirtMaterial, // Group 0: Top Garment (Sweater / T-Shirt)
        pantsMaterial,  // Group 1: Pants / Trousers (Lower Body)
        skinMaterial,   // Group 2: Bare Feet (No shoes, barefoot)
        skinMaterial,   // Group 3: Skin (Hands, Head, Neck, Face)
        eyesMat,        // Group 4: Expressive Eyes
        detailsMat,     // Group 5: Teeth & Oral Details
        eyebrowsMat,    // Group 6: Eyebrows
        lashesMat       // Group 7: Eyelashes
      ];

      // ── 1. Real Anatomical Mesh from Unity UMA ──
      if (typeof RAW_AVATAR_DATA !== 'undefined' && RAW_AVATAR_DATA && RAW_AVATAR_DATA.data) {
        try {
          const loader = new THREE.BufferGeometryLoader();
          const geometry = loader.parse(RAW_AVATAR_DATA);
          geometry.computeVertexNormals();

          const realAvatarMesh = new THREE.Mesh(geometry, materials);
          realAvatarMesh.castShadow = true;
          realAvatarMesh.receiveShadow = true;
          realAvatarMesh.position.set(0, 0.10, 0);
          avatarGroup.add(realAvatarMesh);
        } catch (err) {
          console.error('Failed to parse avatar geometry:', err);
        }
      }

      // ── 2. Tailored Fashion Accents (Ribbed Collar, Hairstyle) ──
      const clothingGroup = buildClothing(IS_FEMALE);
      clothingGroup.position.set(0, 0.10, 0);
      avatarGroup.add(clothingGroup);

      // (Fedora hat completely removed as requested!)

      scene.add(avatarGroup);
    }

    function buildClothing(isFemale) {
      const group = new THREE.Group();
      const CX_H = 0.082;   // Head Center X
      const CZ_H = 0.025;   // Head Center Z

      // (Bare legs and bare feet - no shoes or soles!)

      // ── B. Modern Sleek Hairstyle (Keeps handsome face & eyes 100% visible) ──
      const hairMat = new THREE.MeshStandardMaterial({
        color: isFemale ? 0x2A1C16 : 0x1B1512,
        roughness: 0.85,
        metalness: 0.04
      });

      if (isFemale) {
        // Feminine chic styled hair
        const crownGeo = new THREE.SphereGeometry(0.128, 24, 24);
        crownGeo.scale(0.98, 0.65, 1.10);
        const crown = new THREE.Mesh(crownGeo, hairMat);
        crown.position.set(CX_H, 1.96, CZ_H - 0.025);
        crown.castShadow = true;
        group.add(crown);

        const lockGeo = new THREE.CylinderGeometry(0.036, 0.018, 0.38, 16);
        const lockL = new THREE.Mesh(lockGeo, hairMat);
        lockL.position.set(CX_H - 0.115, 1.70, CZ_H - 0.01);
        lockL.rotation.z = 0.06;
        group.add(lockL);

        const lockR = new THREE.Mesh(lockGeo, hairMat);
        lockR.position.set(CX_H + 0.115, 1.70, CZ_H - 0.01);
        lockR.rotation.z = -0.06;
        group.add(lockR);

        const backHairGeo = new THREE.CylinderGeometry(0.12, 0.09, 0.36, 16);
        backHairGeo.scale(1.08, 1.0, 0.45);
        const backHair = new THREE.Mesh(backHairGeo, hairMat);
        backHair.position.set(CX_H, 1.70, CZ_H - 0.08);
        backHair.castShadow = true;
        group.add(backHair);
      } else {
        // Masculine modern sculpted haircut (flows naturally with skull)
        const hairGeo = new THREE.SphereGeometry(0.120, 32, 24, 0, Math.PI * 2, 0, Math.PI * 0.55);
        hairGeo.scale(0.96, 0.72, 1.05);
        const hairMesh = new THREE.Mesh(hairGeo, hairMat);
        hairMesh.position.set(CX_H, 1.96, CZ_H - 0.02);
        hairMesh.rotation.x = 0.04;
        hairMesh.castShadow = true;
        group.add(hairMesh);
      }

      return group;
    }

    function animate() {
      requestAnimationFrame(animate);

      const elapsed = clock.getElapsedTime();

      if (avatarGroup) {
        avatarGroup.position.y = 0.10 + Math.sin(elapsed * 1.8) * 0.003;
      }

      if (isAutoRotating && avatarGroup) {
        avatarGroup.rotation.y += 0.012;
      }

      controls.update();
      renderer.render(scene, camera);
    }

    function updateDimensions() {
      const container = document.getElementById('canvas-container');
      if (!container) return;
      const width = container.clientWidth || window.innerWidth;
      const height = container.clientHeight || window.innerHeight;
      if (width > 0 && height > 0) {
        camera.aspect = width / height;
        camera.updateProjectionMatrix();
        renderer.setPixelRatio(Math.min(window.devicePixelRatio || 1, 2));
        renderer.setSize(width, height, true);
      }
    }

    function onWindowResize() {
      updateDimensions();
    }

    function resolveColor(c, fallback) {
      if (!c) return fallback || '#222225';
      const colorMap = {
        white: '#FFFFFF',
        black: '#1F1E1D',
        beige: '#EFE5D8',
        cream: '#F4ECE1',
        sand: '#C8A97E',
        blue: '#2B4C7E',
        navy: '#19263E',
        gray: '#7A7A7A',
        grey: '#7A7A7A',
        charcoal: '#222225',
        brown: '#5D4037',
        green: '#2E5A36',
        olive: '#556B2F'
      };
      const s = String(c).trim();
      return colorMap[s.toLowerCase()] || s;
    }

    // ── Public API (Called by Flutter) ──

    window.handleFashionMessage = function(payload) {
      if (!payload) return;
      if (payload.clothing) {
        const cl = payload.clothing;
        const cat = (cl.category || '').toLowerCase();

        // 1. Explicit pantsColor update
        if (cl.pantsColor && pantsMaterial) {
          const hex = resolveColor(cl.pantsColor, '#2B2D31');
          pantsMaterial.color.set(hex);
        }

        // 2. Color attribute update based on category
        if (cl.color) {
          if (cat === 'bottom' || cat === 'pants' || cat === 'trouser') {
            if (pantsMaterial) {
              const hex = resolveColor(cl.color, '#2B2D31');
              pantsMaterial.color.set(hex);
            }
          } else {
            if (tshirtMaterial) {
              const hex = resolveColor(cl.color, '#222225');
              tshirtMaterial.color.set(hex);
            }
          }
        }
      }
    };

    window.setSkinTone = function(toneName) {
      const hex = skinTones[toneName.toLowerCase()] || skinTones.tan;
      if (skinMaterial) {
        skinMaterial.color.setHex(hex);
      }
    };

    window.setCameraView = function(view) {
      isAutoRotating = false;
      const targetPos = new THREE.Vector3(0.04, 1.05, 0);
      controls.target.copy(targetPos);

      switch (view) {
        case 'front':
          camera.position.set(0.04, 1.32, 4.25);
          if (avatarGroup) avatarGroup.rotation.y = 0;
          break;
        case 'threeQuarter':
          camera.position.set(3.00, 1.32, 3.00);
          if (avatarGroup) avatarGroup.rotation.y = 0;
          break;
        case 'side':
          camera.position.set(4.25, 1.32, 0.04);
          if (avatarGroup) avatarGroup.rotation.y = 0;
          break;
        case 'back':
          camera.position.set(0.04, 1.32, -4.25);
          if (avatarGroup) avatarGroup.rotation.y = 0;
          break;
      }
      controls.update();
    };

    window.toggleAutoRotate = function(enable) {
      isAutoRotating = enable;
    };

    window.addEventListener('DOMContentLoaded', init);
  </script>
</body>
</html>
''';
  }
}
