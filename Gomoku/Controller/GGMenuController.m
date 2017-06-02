//
//  GGMenuController.m
//  Gomoku
//
//  Created by Changchang on 2/6/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGMenuController.h"
#import "GGPlayer.h"

@interface GGMenuController ()

@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;
- (IBAction)btnSinglePlayer_TouchUp:(UIButton *)sender;
- (IBAction)btnDoublePlayer_TouchUp:(UIButton *)sender;
- (IBAction)btnSetting_TouchUp:(UIButton *)sender;

@end

@implementation GGMenuController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupBackgroundImage];
}

- (void)setupBackgroundImage {
    self.backgroundImage.translatesAutoresizingMaskIntoConstraints = NO;
    [self.backgroundImage.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor].active = YES;
    [self.backgroundImage.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor].active = YES;
    [self.backgroundImage.widthAnchor constraintEqualToAnchor:self.view.widthAnchor].active = YES;
    [self.backgroundImage.heightAnchor constraintEqualToAnchor:self.view.heightAnchor].active = YES;
}


- (IBAction)btnSinglePlayer_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"startGame" sender:sender];
}

- (IBAction)btnDoublePlayer_TouchUp:(UIButton *)sender {
    [self performSegueWithIdentifier:@"startGame" sender:sender];
}

- (IBAction)btnSetting_TouchUp:(UIButton *)sender {
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    UIButton *button = sender;
    NSLog(@"%@", button.titleLabel.text);
    if ([button.titleLabel.text  isEqual: @"单人游戏"]) {
        // TODO
    } else if ([button.titleLabel.text  isEqual: @"双人游戏"]) {
        // TODO
    }
}
@end
