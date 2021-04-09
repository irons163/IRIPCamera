![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRIPCamera 

- IRIPCamera is a powerful URL/Rtsp/IPCam player/viewer for iOS.

## Features
- Support Rtsp streaming.
- Support for customize connection to your streaming device or IPCam.
- Support demo mode.

## Future
- Support Multi viewer.
- More powerful custom settings.

## Install
### Git
- Git clone this project.

### Cocoapods
- Not support yet.

## Usage

### Basic
- Goto `Setting` Page, then type the URL in the textfield.
    - EX: `rtsp://192.168.2.218`
- OR, you can type `demo` in the textfiled, if you want use demo rtsp url.
  - Demo RTSP URL: `rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov`
- Press `Done` button, then the program will try to connect and play it.

#### How it works?
- Basically, it works by `IRPlayer` + `Live555` + iOS Native API.
    - [IRPlayer](https://github.com/irons163/IRPlayer)
    - [Live555](http://www.live555.com/)
- `Live555` can make a connection with a rtsp server/streaming.
- Decoding the frames by iOS VideoToolbox. The pixel format is NV12.
- `IRPlayer` is the video player which can receive the frames and play it.
    - If you are interested in this part, you can see how it works in `IRFFVideoInput`.
- Playing the audio by iOS AudioToolbox.

### Advanced settings
- Make your custom network connector.
```obj-c
@interface IRCustomStreamConnector : IRStreamConnector
@end
```

- Make your custom network request.
```obj-c
@interface IRCustomStreamConnectionRequest : IRStreamConnectionRequest
@end
```

- Make your custome network response.
```obj-c
@interface IRCustomConnectionResponse : IRStreamConnectionResponse
@end
```

- There are already some codes for custome network connection like IP Cam in this project.
See how the `IRCustomStreamConnector` + `IRCustomStreamConnectionRequest` + `IRStreamConnectionResponse` + `DeviceClass` work.
- The codes for how you connection your IP Cam are not implement(Login, Query, etc...). You need to customize it.

## Screenshots
|Display|Setting|
|---|---|
|![Demo](./ScreenShots/demo1.png)|![Demo](./ScreenShots/demo2.png)|
|![Demo](./ScreenShots/demo3.png)|![Demo](./ScreenShots/demo4.png)|
