import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Stateful widget that automatically rotates the sphere
class Sphere extends StatefulWidget {
  const Sphere.rotate({
    super.key,
    required this.children,
    required this.size,
    bool isRotationX = true,
    bool isRotationY = true, // degrees per second
    double rotationYSpeed = 30.0, // optional vertical angle in degrees
    this.alphaEnabled = true,
    this.isRotate = true,
  }) : rotationX = isRotationX ? 1.0 : 0.0,
       rotationY = isRotationY ? 1.0 : 0.0,
       isGesture = false;

  const Sphere.gesture({
    super.key,
    required this.children,
    required this.size,
    this.alphaEnabled = true,
  }) : rotationX = 0,
       rotationY = 0,
       isGesture = true,
       isRotate = false;

  const Sphere({
    super.key,
    required this.children,
    required this.size,
    this.rotationX = 30.0, // degrees per second
    this.rotationY = 30.0, // optional vertical angle in degrees
    this.alphaEnabled = true,
  }) : isRotate = false,
       isGesture = false;

  final List<Widget> children;
  final double size;
  final double rotationX;
  final double rotationY;
  final bool alphaEnabled;
  final bool isRotate;
  final bool isGesture;

  // final AnimationController? controller;

  @override
  State<Sphere> createState() => _SphereState();
}

class _SphereState extends State<Sphere> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotationXAnimation;
  late final Animation<double> _rotationYAnimation;

  double _rotationX = 0.0;
  double _rotationY = 0.0;
  final double _dragSensitivity = 0.005;

  @override
  void initState() {
    super.initState();
    if (widget.isRotate) {
      _controller = AnimationController(
        vsync: this,
        duration: Duration(seconds: 10),
      )..repeat();
      // Duration is arbitrary, since we'll loop forever
      // Linear rotation from 0 to 360 degrees
      _rotationXAnimation = Tween<double>(
        begin: 0,
        end: 360,
      ).animate(_controller);

      _rotationYAnimation = Tween<double>(
        begin: 0,
        end: 360,
      ).animate(_controller);
    } else {
      _rotationX = 0.0;
      _rotationY = 0.0;
    }
  }

  @override
  void dispose() {
    if (widget.isRotate) {
      _controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isRotate) {
      return AnimatedBuilder(
        animation: _rotationXAnimation,
        builder: (context, child) {
          return SizedBox(
            width: widget.size,
            height: widget.size,
            child: _SphereRenderObject(
              size: widget.size,
              rotationX: widget.rotationX == 0 ? 0 : _rotationXAnimation.value,
              // auto-rotating Y Axis
              rotationY: widget.rotationY == 0 ? 0 : _rotationYAnimation.value,
              // auto-rotating X Axis
              alphaEnabled: widget.alphaEnabled,
              children: widget.children,
            ),
          );
        },
      );
    } else if (widget.isGesture) {
      return RawGestureDetector(
        gestures: {
          PanGestureRecognizer:
              GestureRecognizerFactoryWithHandlers<PanGestureRecognizer>(
                () => PanGestureRecognizer(),
                (PanGestureRecognizer instance) {
                  instance
                    ..onStart = (_) {}
                    ..onUpdate = (details) {
                      setState(() {
                        _rotationX += details.delta.dx * _dragSensitivity;
                        _rotationX = _rotationX % (2 * math.pi);

                        _rotationY -= details.delta.dy * _dragSensitivity;
                      });
                    };
                },
              ),
        },
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: _SphereRenderObject(
            size: widget.size,
            rotationX: _rotationX * 180 / math.pi,
            // degrees
            rotationY: _rotationY * 180 / math.pi,
            // degrees
            alphaEnabled: widget.alphaEnabled,
            children: widget.children,
          ),
        ),
      );
    }
    return _SphereRenderObject(
      size: widget.size,
      rotationX: widget.rotationX,
      rotationY: widget.rotationY,
      alphaEnabled: widget.alphaEnabled,
      children: widget.children,
    );
  }
}

/// SphereGlobe widget that arranges children on a 2D projection of a sphere.
class _SphereRenderObject extends MultiChildRenderObjectWidget {
  const _SphereRenderObject({
    super.key,
    required super.children,
    required this.size,
    this.rotationX = 0, // degrees
    this.rotationY = 0, // degrees
    this.alphaEnabled = true,
  }) : assert(size > 0);

  final double size;
  final double rotationX;
  final double rotationY;
  final bool alphaEnabled;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderSphereBox(
      globeSize: size,
      rotationX: rotationX,
      rotationY: rotationY,
      alphaEnabled: alphaEnabled,
    );
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant RenderSphereBox renderObject,
  ) {
    renderObject
      ..globeSize = size
      ..rotationXDegrees = rotationX
      ..rotationYDegrees = rotationY
      ..alphaEnabled = alphaEnabled;
  }
}

class SphereParentData extends ContainerBoxParentData<RenderBox> {
  Offset topLeft = Offset.zero; // child top-left in local coordinates
  double scale = 1.0;
  double alpha = 1.0;
  double z = 0.0;
}

class RenderSphereBox extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, SphereParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, SphereParentData> {
  RenderSphereBox({
    List<RenderBox>? children,
    required double globeSize,
    required double rotationX,
    required double rotationY,
    required bool alphaEnabled,
  }) : _globeSize = globeSize,
       _rotationXDegrees = rotationX,
       _rotationYDegrees = rotationY,
       _alphaEnabled = alphaEnabled {
    addAll(children);
  }

  double _globeSize;

  double get globeSize => _globeSize;

  set globeSize(double v) {
    if (_globeSize == v) return;
    _globeSize = v;
    _dirtySphere = true;
    markNeedsLayout();
  }

  double _rotationXDegrees;

  double get rotationXDegrees => _rotationXDegrees;

  set rotationXDegrees(double v) {
    if (_rotationXDegrees == v) return;
    _rotationXDegrees = v;
    markNeedsLayout();
  }

  double _rotationYDegrees;

  double get rotationYDegrees => _rotationYDegrees;

  set rotationYDegrees(double v) {
    if (_rotationYDegrees == v) return;
    _rotationYDegrees = v;
    markNeedsLayout();
  }

  bool _alphaEnabled;

  bool get alphaEnabled => _alphaEnabled;

  set alphaEnabled(bool v) {
    if (_alphaEnabled == v) return;
    _alphaEnabled = v;
    markNeedsPaint();
  }

  bool _dirtySphere = true;
  List<_SpherePoint> _points = [];

  void _ensurePoints(int n) {
    if (!_dirtySphere && _points.length == n) return;
    _points = List.generate(n, (i) {
      final invN = (i + 0.5) / n;
      final phi = math.acos(1 - 2 * invN) - (math.pi / 2);
      final theta = math.pi * (1 + math.sqrt(5.0)) * i;
      return _SpherePoint(phi: phi, theta: theta);
    });
    _dirtySphere = false;
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! SphereParentData) {
      child.parentData = SphereParentData();
    }
  }

  @override
  bool get isRepaintBoundary => true;

  @override
  Rect get paintBounds => Rect.largest;

  @override
  void performLayout() {
    size = constraints.constrain(Size(globeSize, globeSize));

    final int count = _childCount;
    _ensurePoints(count);

    final BoxConstraints childConstraints = constraints.loosen();
    final double radius =
        globeSize / 2.0; // use half-size so items sit within bounds
    final double rotationXRad = _degToRad(rotationXDegrees);
    final double rotationYRad = _degToRad(rotationYDegrees);
    final Offset center = Offset(size.width / 2, size.height / 2);

    int index = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      final SphereParentData pd = child.parentData! as SphereParentData;
      child.layout(childConstraints, parentUsesSize: true);

      final _SpherePoint sp = _points[index];

      // initial spherical to Cartesian coordinates
      double x = radius * math.cos(sp.phi) * math.cos(sp.theta);
      double y = radius * math.sin(sp.phi);
      double z = radius * math.cos(sp.phi) * math.sin(sp.theta);

      // --- Apply vertical rotation (X-axis rotation) ---
      double cosY = math.cos(rotationYRad);
      double sinY = math.sin(rotationYRad);
      double y1 = y * cosY - z * sinY;
      double z1 = y * sinY + z * cosY;

      // --- Apply horizontal rotation (Y-axis rotation) ---
      double cosX = math.cos(rotationXRad);
      double sinX = math.sin(rotationXRad);
      double x1 = x * cosX + z1 * sinX;
      double z2 = -x * sinX + z1 * cosX;

      // perspective scale (depth)
      final double scale = 0.3 + 0.7 * ((z2 / radius + 1.0) / 2.0);
      final double depth = math.cos(scale);
      final double finalScale = (scale * 1.95) - depth;
      final double alpha = alphaEnabled
          ? ((scale * 2.0) - 0.98).clamp(0.0, 1.0)
          : 1.0;

      final Offset childCenter = center + Offset(x1, y1);
      final Size scaledChildSize = Size(
        child.size.width * finalScale,
        child.size.height * finalScale,
      );
      final Offset temp =
          childCenter -
          Offset(scaledChildSize.width / 2, scaledChildSize.height / 2);
      final topLeft = Offset(
        temp.dx < 0 ? 0 : temp.dx,
        temp.dy < 0 ? 0 : temp.dy,
      );
      // assert(topLeft.dx >= 0 && topLeft.dy >= 0, '$child is violating');
      pd.topLeft = topLeft;
      pd.scale = finalScale;
      pd.alpha = alpha;
      pd.z = z2;

      child = pd.nextSibling;
      index++;
    }

    // no extra size changes
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    // gather children into list with global offsets for stable ordering
    final List<_PaintItem> items = [];
    RenderBox? child = firstChild;
    while (child != null) {
      final SphereParentData pd = child.parentData! as SphereParentData;
      items.add(
        _PaintItem(
          child: child,
          globalTopLeft: pd.topLeft + offset,
          scale: pd.scale,
          alpha: pd.alpha,
          z: pd.z,
        ),
      );
      child = pd.nextSibling;
    }

    // back-to-front
    items.sort((a, b) => a.z.compareTo(b.z));

    for (final it in items) {
      // build transform: translate to global top-left, then scale (about top-left)
      final Matrix4 transform = Matrix4.identity()
        ..translate(it.globalTopLeft.dx, it.globalTopLeft.dy, 0.0)
        ..scale(it.scale, it.scale, 1.0);

      if (it.alpha < 0.9999) {
        // opacity then transform
        context.pushOpacity(offset, (it.alpha * 255).round().clamp(0, 255), (
          PaintingContext ctx,
          Offset _,
        ) {
          ctx.pushTransform(needsCompositing, Offset.zero, transform, (
            PaintingContext innerCtx,
            Offset __,
          ) {
            innerCtx.paintChild(it.child, Offset.zero);
          });
        });
      } else {
        context.pushTransform(needsCompositing, Offset.zero, transform, (
          PaintingContext innerCtx,
          Offset __,
        ) {
          innerCtx.paintChild(it.child, Offset.zero);
        });
      }
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    RenderBox? child = lastChild; // topmost first
    while (child != null) {
      final SphereParentData pd = child.parentData as SphereParentData;
      final bool isHit = result.addWithPaintOffset(
        offset: pd.offset,
        position: position,
        hitTest: (result, transformed) =>
            child!.hitTest(result, position: transformed),
      );
      if (isHit) return true; // child handles the event
      child = pd.previousSibling;
    }
    return false; // no child hit
  }

  @override
  bool hitTestSelf(Offset position) => true;

  int get _childCount {
    int c = 0;
    RenderBox? child = firstChild;
    while (child != null) {
      c++;
      child = (child.parentData as SphereParentData).nextSibling;
    }
    return c;
  }
}

class _SpherePoint {
  _SpherePoint({required this.phi, required this.theta});

  final double phi;
  final double theta;
}

class _PaintItem {
  _PaintItem({
    required this.child,
    required this.globalTopLeft,
    required this.scale,
    required this.alpha,
    required this.z,
  });

  final RenderBox child;
  final Offset globalTopLeft;
  final double scale;
  final double alpha;
  final double z;
}

double _degToRad(double d) => d * math.pi / 180.0;
