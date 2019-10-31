//
//  IRRTSPSettingsViewController.h
//  IRIPCamera
//
//  Created by Phil on 2019/10/24.
//  Copyright © 2019 Phil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "deviceClass.h"

NS_ASSUME_NONNULL_BEGIN

@protocol IRRTSPSettingsViewControllerDelegate <NSObject>
-(void) updatedSettings:(deviceClass*)device;
@end

@interface IRRTSPSettingsViewController : UIViewController<UITableViewDataSource, UITableViewDelegate>
{
    deviceClass *m_deviceInfo;
    NSInteger m_iCurrentMode;               //Current mode use to display Select mode(if open from ViewEditView) or View Mode
    BOOL m_blnNeedCheckOnLine;
@private
    UITextField* m_currentText;
    CGRect m_screenSize;
    CGFloat mKeyboardHeight;
}

@property (weak) id<IRRTSPSettingsViewControllerDelegate> delegate;
@property (retain, nonatomic) deviceClass *m_deviceInfo;
@property (weak, nonatomic) IBOutlet UISwitch *streamConnectionTypeSwitch;
@property (weak, nonatomic) IBOutlet UITextField *rtspUrlTextfield;
- (IBAction)streamConnectionTypeChanged:(id)sender;

@property (nonatomic) NSInteger m_scrolltoIndex;
@end

NS_ASSUME_NONNULL_END
