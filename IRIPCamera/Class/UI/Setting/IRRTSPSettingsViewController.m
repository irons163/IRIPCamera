//
//  IRRTSPSettingsViewController.m
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "IRRTSPSettingsViewController.h"

#define DEVICE_NAME_EMPTY           0X01
#define DEVICE_ADDRESS_EMPTY        0X02
#define DEVICE_HTTPPORT_EMPTY       0X04
#define DEVICE_UID_EMPTY            0X08
#define DEVICE_USER_EMPTY           0X10
#define DEVICE_PWD_EMPTY            0x20

#define DEVICE_DATACOUNT 6

@interface IRRTSPSettingsViewController ()<UITextFieldDelegate>

@end

@interface IRRTSPSettingsViewController (Private)

- (void)showMessageByTitle:(NSString *)_AlertViewtitle message:(NSString *)_message;
- (NSInteger)checkEditData;
- (void)setNavigationBarItems;
- (void)backButtonPressed;
- (void)doneButtonPress;

@end

@implementation IRRTSPSettingsViewController

@synthesize m_scrolltoIndex;
@synthesize m_deviceInfo;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (CGRect)getScreenSize {
    CGRect rtnRect;
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenHeight = screenRect.size.height;
    CGFloat screenWidth = screenRect.size.width;
    CGFloat setHeight = screenHeight;
    CGFloat setWidth = screenWidth;
    
    if([[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeLeft
       || [[UIApplication sharedApplication] statusBarOrientation] == UIInterfaceOrientationLandscapeRight) {
        setHeight = screenWidth;
        setWidth = screenHeight;
    }
    
    rtnRect = CGRectMake(0, 0, setWidth, setHeight);
    return rtnRect;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    [self.streamConnectionTypeSwitch setOn:[[userDefaults objectForKey:ENABLE_RTSP_URL_KEY] boolValue]];
    [self useRtspURL:[[userDefaults objectForKey:ENABLE_RTSP_URL_KEY] boolValue]];
    self.rtspUrlTextfield.text = [userDefaults objectForKey:RTSP_URL_KEY];
    
    self.m_deviceInfo = [[DeviceClass alloc] init];
    
    [self setNavigationBarItems];
    
    m_blnNeedCheckOnLine = NO;
    
    m_screenSize = [self getScreenSize];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController.navigationBar setHidden:NO];
    
    if (m_deviceInfo) {
        if ([m_deviceInfo.m_deviceAddress length] > 0) {
            NSLog(@"m_deviceInfo.m_deviceAddress=%@", m_deviceInfo.m_strMAC);
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    CGRect tmpRect = self.view.frame;
    tmpRect.size.height = m_screenSize.size.height;
    [self.view setFrame:tmpRect];
    
    [self keyboardWillHide:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)keyboardWillHide:(NSNotification *)aNotification {
    mKeyboardHeight = 0;
    
    CGRect viewrect = self.view.frame;
    viewrect.origin.y = 0.0f;
    [self.view setFrame:viewrect];
}

- (IBAction)streamConnectionTypeChanged:(UISwitch*)sender {
    [self useRtspURL:sender.isOn];
}

- (void)useRtspURL:(BOOL)useRtspURL {
    if(useRtspURL){
        self.rtspUrlTextfield.alpha = 1.0f;
        self.rtspUrlTextfield.userInteractionEnabled = YES;
        //        self.m_tbDevice.alpha = 0.3f;
        //        self.m_tbDevice.userInteractionEnabled = NO;
    }else{
        self.rtspUrlTextfield.alpha = 0.3f;
        self.rtspUrlTextfield.userInteractionEnabled = NO;
        //        self.m_tbDevice.alpha = 1.0f;
        //        self.m_tbDevice.userInteractionEnabled = YES;
    }
}

@end

@implementation IRRTSPSettingsViewController (Private)

- (void)showMessageByTitle:(NSString *)_AlertViewtitle message:(NSString *)_message {
    NSString *strCancelBtn = _(@"ButtonTextOk");
    UIAlertView *tmpAlert = [[UIAlertView alloc] initWithTitle:_AlertViewtitle message:_message
                                                      delegate:nil cancelButtonTitle:strCancelBtn
                                             otherButtonTitles:nil, nil ];
    [tmpAlert show];
}

- (NSInteger)checkEditData {
    int iRtn = 0;
    BOOL blnNameEmpty = NO;
    BOOL blnAddressEmpty = NO;
    BOOL blnPortEmpty = NO;
    BOOL blnUserEmpty = NO;
    BOOL blnPassowrdEmpty = NO;
    
    if(m_deviceInfo.m_deviceName == nil)
    {
        //        iRtn |= DEVICE_NAME_EMPTY;
        blnNameEmpty = YES;
    }
    else
    {
        if([[m_deviceInfo.m_deviceName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        {
            //            iRtn |= DEVICE_NAME_EMPTY;
            blnNameEmpty = YES;
        }
    }
    
    if (m_deviceInfo.m_deviceAddress == nil)
    {
        //            iRtn |= DEVICE_ADDRESS_EMPTY;
        blnAddressEmpty = YES;
    }
    else
    {
        if([[m_deviceInfo.m_deviceAddress stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        {
            //                iRtn |= DEVICE_ADDRESS_EMPTY;
            blnAddressEmpty = YES;
        }
    }
    
    if(m_deviceInfo.m_httpPort.httpPort <= 0)
    {
        //            iRtn |= DEVICE_HTTPPORT_EMPTY;
        blnPortEmpty = YES;
    }
    
    
    if(m_deviceInfo.m_userName == nil)
    {
        //        iRtn |= DEVICE_NAME_EMPTY;
        blnUserEmpty = YES;
    }
    else
    {
        if([[m_deviceInfo.m_userName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        {
            //            iRtn |= DEVICE_NAME_EMPTY;
            blnUserEmpty = YES;
        }
    }
    
    if(m_deviceInfo.m_password == nil)
    {
        //        iRtn |= DEVICE_NAME_EMPTY;
        blnPassowrdEmpty = YES;
    }
    else
    {
        if([[m_deviceInfo.m_password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0)
        {
            //            iRtn |= DEVICE_NAME_EMPTY;
            blnPassowrdEmpty = YES;
        }
    }
    
    if(blnNameEmpty)
        iRtn += DEVICE_NAME_EMPTY;
    
    if(blnAddressEmpty)
        iRtn += DEVICE_ADDRESS_EMPTY;
    
    if(blnPortEmpty)
        iRtn += DEVICE_HTTPPORT_EMPTY;
    
    if(blnUserEmpty)
        iRtn += DEVICE_USER_EMPTY;
    
    if(blnPassowrdEmpty)
        iRtn += DEVICE_PWD_EMPTY;
    
    return iRtn;
}

- (void)setNavigationBarItems {
    self.title = _(@"SettingsTitle");
    
    UIButton *btnLeft = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
    [btnLeft setTitle:_(@"ButtonTextBack") forState:UIControlStateNormal];
    [btnLeft setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnLeft addTarget:self action:@selector(backButtonPressed) forControlEvents:UIControlEventTouchDown];
    
    UIButton *btnRight = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 55, 44)];
    [btnRight setTitle:_(@"ButtonTextDone") forState:UIControlStateNormal];
    [btnRight setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btnRight addTarget:self action:@selector(doneButtonPress) forControlEvents:UIControlEventTouchDown];
    
    UIBarButtonItem *leftitem = [[UIBarButtonItem alloc] initWithCustomView:btnLeft];
    UIBarButtonItem *rightitem = [[UIBarButtonItem alloc] initWithCustomView:btnRight];
    
    self.navigationItem.leftBarButtonItem =leftitem;
    self.navigationItem.rightBarButtonItem =rightitem;
}

- (void)doneButtonPress {
    NSInteger iCheck = 0;
    NSString *strMsg = @"";
    NSString *strTitle = [NSString stringWithFormat:@"%@" ,_(@"ModifySaveError")];
    
    if(m_currentText)
        [m_currentText resignFirstResponder];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    if(self.streamConnectionTypeSwitch.isOn){
        [userDefaults setBool:self.streamConnectionTypeSwitch.isOn forKey:ENABLE_RTSP_URL_KEY];
        if([self.rtspUrlTextfield.text isEqualToString:@"demo"])
            self.rtspUrlTextfield.text = @"rtsp://wowzaec2demo.streamlock.net/vod/mp4:BigBuckBunny_115k.mov";
        [userDefaults setObject:self.rtspUrlTextfield.text forKey:RTSP_URL_KEY];
        [userDefaults synchronize];
        [self.delegate updatedSettings:m_deviceInfo];
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if ((iCheck = [self checkEditData]) == 0) {
        [userDefaults setBool:self.streamConnectionTypeSwitch.isOn forKey:ENABLE_RTSP_URL_KEY];
        [userDefaults setObject:self.rtspUrlTextfield.text forKey:RTSP_URL_KEY];
        [userDefaults synchronize];
        [self.delegate updatedSettings:m_deviceInfo];
        [self.navigationController popViewControllerAnimated:YES];
        strMsg = @"DB Error.";
        [self showMessageByTitle:strTitle message:strMsg];
    } else {
        if(iCheck & DEVICE_NAME_EMPTY)
        {
            strMsg = [strMsg stringByAppendingFormat:@"%@\n",_(@"ModifyDeviceError_DeviceName")];
        }
        
        if (iCheck & DEVICE_ADDRESS_EMPTY) {
            strMsg=[strMsg stringByAppendingFormat:@"%@\n",_(@"ModifyDeviceError_Address")];
        }
        
        if (iCheck & DEVICE_HTTPPORT_EMPTY) {
            strMsg=[strMsg stringByAppendingFormat:@"%@\n",_(@"ModifyDeviceError_HttpPort")];
        }
        
        if (iCheck & DEVICE_USER_EMPTY) {
            strMsg = [strMsg stringByAppendingFormat:@"%@\n",_(@"ModifyDeviceError_UserName")];
        }
        
        if (iCheck & DEVICE_PWD_EMPTY) {
            strMsg = [strMsg stringByAppendingFormat:@"%@\n",_(@"ModifyDeviceError_Password")];
        }
        
        [self showMessageByTitle:strTitle message:strMsg];
    }
}

- (void)backButtonPressed {
    if(m_currentText)
        [m_currentText resignFirstResponder];
    
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Wide Functions
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    return [textField resignFirstResponder];
}

@end
