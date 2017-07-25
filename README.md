# OC_VS_RN
OC与ReactNative之间的通信

### 20170725 
#### 最近在做react原生开发，接到react-native的研究工作，主要需要搞清楚的是如何让RN与IOS开发相结合，毕竟移动端很多底层的东西还是需要原生来支持效果会更好。
当前工程中实现了：
1. RN调用OC获取设备唯一号，并在RN展示
2. RN调用OC播放暂停音频，OC回调RN告知播放状态
3. RN从OC拉取文档列表数据，并在RN中以列表展示，点击某文档后通知OC打开选中的文档
这里省略许多研究过程，直接看成果。

### 创建工程
- react-native init --version="0.44.0" OC_VS_RN (这个命令可以一步到位创建RN工程，OC_VS_RN是工程名称。这里需要注意的是目前0.44比较稳定，新建项目制定version才不会编译出错)
- cd到OC_VS_RN目录后 执行命令：npm install（这个命令会自动安装RN所需的所有库）
- 如果你下载了本项目，你除了需要执行npm install 命令，还需要cd到ios目录，并执行命令：pod update --verbose（ios项目用到了我的第三方，方便之后的开发）  
 
### OC 通信 RN
#### OC 模块 (OCvsRN.h OCvsRN.m)
- 首先需要创建一个继承于RCTEventEmitter的类并实现RCTBridgeModule接口，这里创建了OCvsRN.h
    
```
#import <Foundation/Foundation.h>
//需要导入的库
#import <React/RCTBridgeModule.h>
#import <React/RCTEventEmitter.h> 
@interface OCvsRN : RCTEventEmitter<RCTBridgeModule>
@end
``` 
- 在OCvsRN.m文件中你需要添加2行代码

```
@synthesize bridge = _bridge;
RCT_EXPORT_MODULE(); 
```
- 实现方法-(NSArray<NSString *> *)supportedEvents，在这个方法中，需要添加所有OC与RN互调的方法名称字符串（OC的方法名称functionName及sendEventWithName的事件名称eventName）。测试发现functionName与eventName可以共用，获取设备唯一号仅实现了fetchUUID，没有区分是functionName还是eventName，这可以说明情况。具体实现可参考：

```
-(NSArray<NSString *> *)supportedEvents {
  return @[
            @"fetchUUID",//拉取设备唯一号，functionName与eventName共用
            @"ocFuncFetchDocList",//拉取文档列表
            @"ocFuncPlayMusic",//播放音频
            @"ocFuncPlayOrPause",//播放或暂停
            @"ocFuncOpenDoc",//打开文档
            @"docListSendToRN",//文档列表从OC发送到RN
            @"musicStatusSendToRN",//音频状态从OC发送到RN
           ];
}
```
- OC中公布给RN调用的方法，使用宏命令方式来定义。下面的2个方法，第一个是无参数调用，第二个为有参数调用

```
RCT_EXPORT_METHOD(fetchUUID) {
    ... 
}
RCT_EXPORT_METHOD(ocFuncOpenDoc:(NSString *) doc) {
    ...
}
```
- OC调用RN，使用sendEventWithName:body:方法。参数为eventName和body，body为需要发送的参数对象，可以是字符串或字典或数组。 

```
[self sendEventWithName:@"fetchUUID" body:token];
```

至此，OC端需要做的工作就完成了。

#### RN 模块 （index.ios.js）
- 首先需要定义

```
var NativeBridge = NativeModules.OCvsRN;
const NativeModule = new NativeEventEmitter(NativeBridge);
```
- 其次

```
componentWillUnmount() {
    this.NativeModule.remove();
}
```
- 定义event处理接口，NativeModule.addListener(name,(data)=>{})，这里的name对应了OC端sendEventWithName中的eventName，data对应body

```
componentDidMount() {
    let context = this; 
    NativeModule.addListener(
        'fetchUUID',
        (data) => {
            context.setState({
                uniqueID: data,
            })
        }
    );
}
```
- RN调用OC，NativeBridge.functionName，这里的functionName对应了OC中公布的方法名称functionName

```
NativeBridge.fetchUUID()//无参数调用
NativeBridge.ocFuncOpenDoc(rowData)//有参数调用
```
至此RN端需要做的工作就完成了。

### 对比

| 对比 | OC | RN |
| --- | --- | --- |
| OC需继承及实现接口 | 继承RCTEventEmitter，实现接口RCTBridgeModule。 |  无 | 
| 定义 | @synthesize bridge = _bridge; RCT_EXPORT_MODULE(); | var NativeBridge = NativeModules.OCvsRN; const NativeModule = new NativeEventEmitter(NativeBridge); | 
| OC需声明支持的命令，RN需在卸载前移除定义 | -(NSArray<NSString *> *)supportedEvents  | componentWillUnmount() {this.NativeModule.remove();} |
| OC需公布方法，RN需添加监听并实现OC回调 | RCT_EXPORT_METHOD(xxx) |  NativeModule.addListener('xxx',(data) => {}); |
| 调用方式 | sendEventWithName:body: | NativeBridge.xxx |

 
 



