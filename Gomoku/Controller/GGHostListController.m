//
//  GGHostListController.m
//  Gomoku
//
//  Created by Changchang on 11/7/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGHostListController.h"
@import CocoaAsyncSocket; 

@interface GGHostListController ()

@property (strong, nonatomic) UIAlertController *alertController;

@end

@implementation GGHostListController

- (void)viewDidLoad {
    [super viewDidLoad];
    //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    
}

- (void)startBroadcast {
    
}

#pragma mark - IBAction

- (IBAction)btnBack_TouchUp:(UIBarButtonItem *)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)btnCreateGame_TouchUp:(UIBarButtonItem *)sender {
    [self startBroadcast];
    
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"Waiting for player to join in..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil];
        [_alertController addAction:action];
    }
    [self presentViewController:_alertController animated:YES completion:nil];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    cell.textLabel.text = @"123";
    
    return cell;
}


@end
