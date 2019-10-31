//
//  ViewController.m
//  IRIPCamera
//
//  Created by Phil on 2019/9/6.
//  Copyright © 2019 Phil. All rights reserved.
//

#import "ViewController.h"
#import "IRRTSPPlayer.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"RTSP Player";
            break;
        case 1:
            cell.textLabel.text = @"Media Player";
            break;
        case 2:
            cell.textLabel.text = @"Download Player";
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *player;
    NSString *videoPathUrl = @"http://192.168.0.116:9000/usb_admin/storage/sdcard/video/20180524/11/sched_video_20180524-114010.avi";
//    NSString *videoPathUrl = @"https://mnmedias.api.telequebec.tv/m3u8/29880.m3u8";
    switch (indexPath.row) {
        case 0:
            player = [storyboard instantiateViewControllerWithIdentifier:@"IRRTSPPlayer"];
            //    [self presentViewController:player animated:YES completion:nil];
            [self.navigationController pushViewController:player animated:YES];
            break;
        case 1:
            break;
        case 2:
            break;
        default:
            break;
    }
}

@end
