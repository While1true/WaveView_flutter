### flutter自定义波浪view

![waveview.gif](https://github.com/While1true/WaveView_flutter/blob/master/waveview.gif)
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

1.自定义view动画的步骤
> 原生自定义view是继承view，重写onMeasure和Ondraw方法，在ondraw中在canvas中画出图形，再通过Animator控制变量值，来达到动画效果

> flutter 是继承CustomPainter 实现paint方法，在paint方法中画出图形，再通过AntimationController控制变量值，达到动画效果。再将CustomPainter 实例作为参数传给CustomPaint，就达成了。

>由于都出自google 重原生ondraw方法移植到flutter的paint方法十分容易。两者的Canvas，Paint，Path等类Api都是很相似。


---
#### 开始移植工作
  
1. 原理
###### 学过物理的都知道正旋波等，声波的概念。
- [y=A*sin(Wt+ Q];
- 可以通过A控制振幅，W控制频率，Q控制x轴位移
- 在控制A和w都不变的情况下，先画好静态波浪，我们只需要讲Q换成变量，然后用动画控制偏移量，达到波移动的效果

#### 画出波浪

- 把画板假象为带有一个坐标轴
- 最左边为x=0处，view底部或波浪中部作为y=0处
- 计算x->屏幕宽度取值下的y的值，将这些点加入到一个path，就绘制出了波浪线,多个波纹，用同样的方法
-
```
    path1.moveTo(0.0,viewCenterY -waveAmplifier * _getSinY(wavePhaseValue.value, waveFrequency, -1));
    for (int i = 0; i < size.width - 1; i++) {
      path1.lineTo((i + 1).toDouble(), viewCenterY -waveAmplifier * _getSinY(wavePhaseValue.value, waveFrequency, (i + 1)));
    }
    path1.lineTo(size.width, size.height);
    path1.lineTo(0.0, size.height);
    path1.close();
```

#### 动画控制
- 初始化一个AnimationController，并将其作为参数传给CustomPainter的repaint。它将自动监听controller的动画驱动值，重绘调用paint方法
- 新建一个Tween动画，将控制位移的动画值Animation<double>传给paint，paint中取这个动画值来绘制，就实现了动画效果
-
```
 _waveControl =new AnimationController(vsync: this, duration: Duration(seconds: 2));
_wavePhaseValue =Tween(begin: widget.wavePhase, end: 360 + widget.wavePhase)
                 .animate(_waveControl);
 _wavePhaseValue.addStatusListener((s) {
      if (s == AnimationStatus.completed) {
        _waveControl.reset();
        _waveControl.forward();
      }
    });
    _waveControl.forward();

```

```
 Copyright [2018] [While1true]

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
```
