# WaveView_flutter
a self waveView of flutter


![2017-08-19-12-02-52.gif](http://upload-images.jianshu.io/upload_images/6456519-f48b62df0147c5da.gif?imageMogr2/auto-orient/strip)

> 原理：正弦曲线y=a*sin(b*α+c)+m;

> a:控制振幅  b:控制波长 c:控制轴偏移  m:控制y轴偏移 α：角度

> 思路：画出波的path，通过动画控制振幅a达到水波的起伏效果<br>控制c的值达到移动效果
---
```
WaveWidget(
            imageProvider:NetworkImage(userInfo.user_url),
            size: Size(MediaQuery.of(context).size.width, 250.0),
            bgColor: ColorValues.primaryColor,
          )



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
