# WaveView_flutter
a self waveView of flutter
---![2017-08-19-12-02-52.gif](http://upload-images.jianshu.io/upload_images/6456519-f48b62df0147c5da.gif?imageMogr2/auto-orient/strip)

> 原理：正弦曲线y=a*sin(b*α+c)+m;

> a:控制振幅  b:控制波长 c:控制轴偏移  m:控制y轴偏移 α：角度

> 思路：画出波的path，通过动画控制振幅a达到水波的起伏效果<br>控制c的值达到移动效果
---
```
WaveWidget(
      {this.imageProvider,
      @required this.size,
      this.imgSize = const Size(60.0, 60.0),
      this.imgOffset = const Offset(0.0, 0.0),
      this.waveAmplifier = 10.0,
      this.waveFrequency = 1.6,
      this.wavePhase = 10.0,
      this.bgColor,
      this.rountImg = true,
      this.heightPercentange = 6 / 7});
 ```
