//
// Created by ckckck on 2018/9/19.
//

import 'dart:math';

import 'package:flutter/material.dart' hide Image;
import 'dart:ui' show Image;

class WaveWidget extends StatefulWidget {
  /**
   * 控件大小
   */
  Size size;

  /**
   * 浮动图标大小
   */
  Size imgSize;

  /**
   * 图标偏移
   */
  Offset imgOffset;

  /**
   * 振幅
   */
  double waveAmplitude;

  /**
   * 角度偏移
   */
  double wavePhase;

  /**
   * 频率
   */
  double waveFrequency;

  /**
   * x轴位置百分比
   */
  double heightPercentange;

  /**
   * 图像圆形裁剪
   */
  bool roundImg;
  ImageProvider<dynamic> imageProvider;
  Color bgColor;

  WaveWidget(
      {this.imageProvider,
      @required this.size,
      this.imgSize = const Size(60.0, 60.0),
      this.imgOffset = const Offset(0.0, 0.0),
      this.waveAmplitude = 10.0,
      this.waveFrequency = 1.6,
      this.wavePhase = 10.0,
      this.bgColor,
      this.roundImg = true,
      this.heightPercentange = 6 / 7});

  @override
  State<StatefulWidget> createState() => _WaveWidgetState();
}

class _WaveWidgetState extends State<WaveWidget> with TickerProviderStateMixin {
  AnimationController _waveControl;
  Animation<double> _wavePhaseValue;
  Image image;
  bool _isListeningToStream = false;
  ImageStream _imageStream;
  Size imgSize;

  @override
  void initState() {
    super.initState();
    imgSize = widget.imgSize;
    _waveControl =
        new AnimationController(vsync: this, duration: Duration(seconds: 2));
    _wavePhaseValue =
        Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
            .animate(_waveControl);
    _wavePhaseValue.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _waveControl.reset();
        _waveControl.forward();
      }
    });
    if (widget.imageProvider == null) {
      _waveControl.forward();
    }
  }

  @override
  void didChangeDependencies() {
    _resolveImage();

    if (TickerMode.of(context))
      _listenToStream();
    else
      _stopListeningToStream();

    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(WaveWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.imageProvider != oldWidget.imageProvider) _resolveImage();
  }

  @override
  void reassemble() {
    _resolveImage(); // in case the image cache was flushed
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _MyWavePaint(
          image: image,
          bgColor: widget.bgColor,
          imageSize: imgSize,
          heightPercentange: widget.heightPercentange,
          repaint: _waveControl,
          imgOffset: widget.imgOffset,
          roundImg: widget.roundImg,
          waveFrequency: widget.waveFrequency,
          wavePhaseValue: _wavePhaseValue,
          waveAmplitude: widget.waveAmplitude),
      size: widget.size,
    );
  }

  void _updateSourceStream(ImageStream newStream) {
    if (_imageStream?.key == newStream?.key) return;

    if (_isListeningToStream) _imageStream.removeListener(_handleImageChanged);

    _imageStream = newStream;
    if (_isListeningToStream) _imageStream.addListener(_handleImageChanged);
  }

  void _listenToStream() {
    if (_isListeningToStream) return;
    _imageStream.addListener(_handleImageChanged);
    _isListeningToStream = true;
  }

  void _stopListeningToStream() {
    if (!_isListeningToStream) return;
    _imageStream.removeListener(_handleImageChanged);
    _isListeningToStream = false;
  }

  @override
  void dispose() {
    assert(_imageStream != null);
    _stopListeningToStream();
    _waveControl.dispose();
    widget.imageProvider.evict();
    super.dispose();
  }

  void _resolveImage() {
    try {
      var asset = widget.imageProvider;
      final ImageStream newStream = asset.resolve(
          createLocalImageConfiguration(context, size: widget.imgSize));
      assert(newStream != null);
      _updateSourceStream(newStream);
    } catch (e) {
      print(e);
    }
  }

  void _handleImageChanged(ImageInfo imageInfo, bool synchronousCall) {
    if (imageInfo == null) {
      return;
    }
    _caculatePercentangeSize(imageInfo);
    setState(() {
      image = imageInfo.image;
      _waveControl.forward();
    });
  }

  /**
   * 按等宽或等高计算宽高，当给定的宽高为0
   * 都为0时为图片原尺寸
   */
  void _caculatePercentangeSize(ImageInfo imageInfo) {
    if (imgSize.width == 0.0 && imgSize.height == 0.0) {
      imgSize = Size(
          imageInfo.image.width.toDouble(), imageInfo.image.height.toDouble());
    } else if (imgSize.isEmpty) {
      if (imgSize.width == 0.0) {
        imgSize = Size(
            imageInfo.image.width * imgSize.height / imageInfo.image.height,
            imgSize.height);
      } else {
        imgSize = Size(imgSize.width,
            imageInfo.image.height * imgSize.width / imageInfo.image.width);
      }
    }
  }
}

class _MyWavePaint extends CustomPainter {
  _MyWavePaint(
      {this.image,
      this.imageSize,
      this.imgOffset,
      this.bgColor,
      this.heightPercentange,
      this.waveFrequency,
      this.wavePhaseValue,
      this.roundImg = true,
      this.waveAmplitude,
      Listenable repaint})
      : super(repaint: repaint);

  /**
   * 振幅
   */
  double waveAmplitude;

  /**
   * 角度
   */
  Animation<double> wavePhaseValue;

  /**
   * 频率
   */
  double waveFrequency;

  /**
   * x轴位置百分比
   */
  double heightPercentange;

  /**
   * 图标偏移
   */
  Offset imgOffset;
  bool roundImg;
  Image image;
  Color bgColor;
  Size imageSize;
  Path path1 = Path();
  Path path2 = Path();
  Path path3 = Path();
  double _tempa = 0.0;
  double _tempb = 0.0;
  double viewWidth = 0.0;
  Paint mPaint = Paint();
  Rect rect;

  @override
  void paint(Canvas canvas, Size size) {
    waveAmplitude =
        (waveAmplitude * 2 > size.width) ? (size.height / 2) : waveAmplitude;
    var viewCenterY = size.height * heightPercentange;
    viewWidth = size.width;
    if (bgColor != null) {
      mPaint.color = bgColor;
      if (rect == null) {
        rect = Rect.fromLTRB(0.0, 0.0, size.width, size.height);
      }
      canvas.drawRect(rect, mPaint);
    }
    _fillPath(viewCenterY, size);

    mPaint.color = Color(0xc0ffffff);
    canvas.drawPath(path1, mPaint);

    mPaint.color = Color(0xB0ffffff);
    canvas.drawPath(path2, mPaint);

    _drawImg(viewCenterY, canvas);

    mPaint.color = Color(0x80ffffff);
    canvas.drawPath(path3, mPaint);
  }

  void _fillPath(double viewCenterY, Size size) {
    path1.reset();
    path2.reset();
    path3.reset();
    path1.moveTo(
        0.0,
        viewCenterY -
            waveAmplitude * _getSinY(wavePhaseValue.value, waveFrequency, -1));
    path2.moveTo(
        0.0,
        viewCenterY -
            1.3 *
                waveAmplitude *
                _getSinY(wavePhaseValue.value + 90, waveFrequency, -1));
    path3.moveTo(
        0.0,
        viewCenterY +
            waveAmplitude * _getSinY(wavePhaseValue.value, waveFrequency, -1));

    for (int i = 0; i < size.width - 1; i++) {
      path1.lineTo(
          (i + 1).toDouble(),
          viewCenterY -
              waveAmplitude *
                  _getSinY(wavePhaseValue.value, waveFrequency, (i + 1)));
      path2.lineTo(
          (i + 1).toDouble(),
          viewCenterY -
              1.3 *
                  waveAmplitude *
                  _getSinY(
                      wavePhaseValue.value + 90, 0.8 * waveFrequency, (i + 1)));
      path3.lineTo(
          (i + 1).toDouble(),
          viewCenterY +
              waveAmplitude *
                  _getSinY(wavePhaseValue.value, waveFrequency, -1));
    }
    path1.lineTo(size.width, size.height);
    path2.lineTo(size.width, size.height);
    path3.lineTo(size.width, size.height);

    path1.lineTo(0.0, size.height);
    path2.lineTo(0.0, size.height);
    path3.lineTo(0.0, size.height);

    path1.close();
    path2.close();
    path3.close();
  }

  void _drawImg(double viewCenterY, Canvas canvas) {
    if (image != null) {
      mPaint.color = Color(0xffffffff);
      var offset = Offset(
          viewWidth / 2 - imageSize.width / 2,
          viewCenterY -
              1.3 *
                  waveAmplitude *
                  _getSinY(wavePhaseValue.value + 90, waveFrequency * 0.8,
                      (viewWidth / 2 + 1).toInt()) -
              imageSize.height);
      var destRect = Rect.fromLTRB(
          offset.dx + imgOffset.dx,
          offset.dy + imgOffset.dy,
          offset.dx + imgOffset.dx + imageSize.width,
          offset.dy + imageSize.height + imgOffset.dy);
      if (roundImg) {
        var clipOvalRect=destRect;
        canvas.save();
        /**
         * 计算圆形裁剪区域
         */
        if (destRect.width != destRect.height) {
          var djust = (destRect.width - destRect.height).abs() / 2;
          if (destRect.width > destRect.height) {
            clipOvalRect = Rect.fromLTRB(destRect.left + djust, destRect.top,
                destRect.right - djust, destRect.bottom);
          } else {
            clipOvalRect = Rect.fromLTRB(destRect.left, destRect.top + djust,
                destRect.right, destRect.bottom - djust);
          }
        }
        canvas.clipPath(Path()..addOval(clipOvalRect));
      }
      canvas.drawImageRect(
          image,
          Rect.fromLTRB(
              0.0, 0.0, image.width.toDouble(), image.height.toDouble()),
          destRect,
          mPaint);
      if (roundImg) {
        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(_MyWavePaint oldDelegate) {
    return false;
  }

  double _getSinY(
      double startradius, double waveFrequency, int currentposition) {
    //避免重复计算，提取公用值
    if (_tempa == 0) _tempa = pi / viewWidth;
    if (_tempb == 0) {
      _tempb = 2 * pi / 360.0;
    }
    return (sin(
        _tempa * waveFrequency * (currentposition + 1) + startradius * _tempb));
  }
}
