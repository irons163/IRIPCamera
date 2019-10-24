![Build Status](https://img.shields.io/badge/build-%20passing%20-brightgreen.svg)
![Platform](https://img.shields.io/badge/Platform-%20iOS%20-blue.svg)

# IRSingleButtonGroup 

- IRSingleButtonGroup is a powerful buttons group framework for iOS.

## Features

- Single Button Selection.
- Single Button Selection Demo: Deselect able.
- Multi Buttons Selection.

## Install
### Cocoapods
- Add `pod 'IRSingleButtonGroup'`  in the `Podfile`
- `pod install`

## Usage

- more examples in the demo applications.

### Basic

```obj-c

IRSingleButtonGroup* singleButtonGroup = [[IRSingleButtonGroup alloc] init];
singleButtonGroup.buttons = @[self.button1, self.button2, self.button3];
singleButtonGroup.delegate = self;

#pragma mark - SingleButtonGroupDelegate
- (void)didSelectedButton:(UIButton *)button {
    NSLog(@"Button%ld", button.tag);
}

- (void)didDeselectedButton:(UIButton *)button {
    NSLog(@"Button%ld", button.tag);
}
```

### Advanced settings
```obj-c
singleButtonGroup.canMultiSelected = NO;
singleButtonGroup.canSelectWhenSelected = YES;
[singleButtonGroup setInitSelected:0];
```

## Screenshots
![Demo](./demo/ScreenShots/demo1.png)
