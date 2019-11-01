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
    [self.navigationController.navigationBar setHidden:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (nonnull UITableViewCell *)tableView:(nonnull UITableView *)tableView cellForRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    switch (indexPath.row) {
        case 0:
            cell.textLabel.text = @"RTSP Player";
            break;
    }
    
    return cell;
}

- (NSInteger)tableView:(nonnull UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *player;
    switch (indexPath.row) {
        case 0:
            player = [storyboard instantiateViewControllerWithIdentifier:@"IRRTSPPlayer"];
            [self.navigationController pushViewController:player animated:YES];
            break;
        default:
            break;
    }
}

@end
