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
- Goto `Setting` Page, then key in the URL in the textfield.
- OR, you can key in `demo` in the textfiled, if you want use demo rtsp url.
- Press `Done` button, then the program will try to connect and play it.

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
![Demo](./ScreenShots/demo1.png)
![Demo](./ScreenShots/demo2.png)
