//
//  GGHostListController.m
//  Gomoku
//
//  Created by Changchang on 11/7/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGHostListController.h"
#import "GGPacket.h"
@import CocoaAsyncSocket; 

@interface GGHostListController () <NSNetServiceDelegate, NSNetServiceBrowserDelegate, GCDAsyncSocketDelegate>

@property (strong, nonatomic) UIAlertController *alertController;

@property (strong, nonatomic) NSNetService *serverService;
@property (strong, nonatomic) GCDAsyncSocket *serverSocket;

@property (strong, nonatomic) GCDAsyncSocket *clientSocket;
@property (strong, nonatomic) NSMutableArray *services;
@property (strong, nonatomic) NSNetServiceBrowser *serviceBrowser;

@end

@implementation GGHostListController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self startBrowsing];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSUserDefaults *pref = [NSUserDefaults standardUserDefaults];
    if ([pref objectForKey:@"LAN_mode_tip_showed"] == nil) {
        [pref setObject:@1 forKey:@"LAN_mode_tip_showed"];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"局域网对战" message:@"请确保您和对方的手机处于同一局域网下，以保证局域网联机顺利进行" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleCancel handler:nil];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    }
    
    
}

- (void)startBroadcast {
    // Initialize GCDAsyncSocket
    self.serverSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    
    // Start Listening for Incoming Connections
    NSError *error = nil;
    if ([self.serverSocket acceptOnPort:0 error:&error]) {
        // Initialize Service
        self.serverService = [[NSNetService alloc] initWithDomain:@"local." type:@"_gomoku._tcp." name:@"" port:[self.serverSocket localPort]];
        
        // Configure Service
        [self.serverService setDelegate:self];
        
        // Publish Service
        [self.serverService publish];
        
    } else {
        NSLog(@"Unable to create socket. Error %@ with user info %@.", error, [error userInfo]);
    }
}

- (void)stopBroadcast {
    if (self.serverService) {
        self.serverService.delegate = nil;
        [self.serverService stop];
        self.serverService = nil;
        
//        self.serverSocket.delegate = nil;
        [self.serverSocket disconnect];
    }
}

- (void)startBrowsing {
    if (self.services) {
        [self.services removeAllObjects];
    } else {
        self.services = [[NSMutableArray alloc] init];
    }
    
    // Initialize Service Browser
    self.serviceBrowser = [[NSNetServiceBrowser alloc] init];
    
    // Configure Service Browser
    [self.serviceBrowser setDelegate:self];
    [self.serviceBrowser searchForServicesOfType:@"_gomoku._tcp." inDomain:@"local."];
}

- (void)stopBrowsing {
    if (self.serviceBrowser) {
        [self.serviceBrowser stop];
        [self.serviceBrowser setDelegate:nil];
        self.serviceBrowser = nil;
    }
}

- (BOOL)connectWithService:(NSNetService *)service {
    BOOL isConnected = NO;
    NSArray *addresses = [[service addresses] mutableCopy];
    
    if (!self.clientSocket || ![self.clientSocket isConnected]) {
        NSLog(@"Initializing socket");
        // Initialize Socket
        self.clientSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        // Connect
        while (!isConnected && [addresses count]) {
            NSData *address = [addresses objectAtIndex:0];
            
            NSError *error = nil;
            if ([self.clientSocket connectToAddress:address error:&error]) {
                isConnected = YES;
                
            } else if (error) {
                NSLog(@"Unable to connect to address. Error %@ with user info %@.", error, [error userInfo]);
            }
        }
        
    } else {
        isConnected = [self.clientSocket isConnected];
    }
    
    return isConnected;
}


#pragma mark - IBAction

- (IBAction)btnBack_TouchUp:(UIBarButtonItem *)sender {
    [self stopBrowsing];
    [self.clientSocket setDelegate:nil];
    [self.clientSocket disconnect];
    self.clientSocket = nil;
    [self.delegate shouldDismiss];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (IBAction)btnCreateGame_TouchUp:(UIBarButtonItem *)sender {
    [self startBroadcast];
    
    if (_alertController == nil) {
        _alertController = [UIAlertController alertControllerWithTitle:@"正在等待其他玩家加入..." message:@"" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            [self stopBroadcast];
        }];

        [_alertController addAction:action];
    }
    [self presentViewController:_alertController animated:YES completion:nil];
}


#pragma mark - NSNetServiceDelegate

- (void)netServiceDidPublish:(NSNetService *)service {
    NSLog(@"Bonjour Service Published: domain(%@) type(%@) name(%@) port(%i)", [service domain], [service type], [service name], (int)[service port]);
}

- (void)netService:(NSNetService *)service didNotPublish:(NSDictionary *)errorDict {
    NSLog(@"Failed to Publish Service: domain(%@) type(%@) name(%@) - %@", [service domain], [service type], [service name], errorDict);
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    sender.delegate = nil;
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender {
    if ([self connectWithService:sender]) {
        NSLog(@"Did Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    } else {
        NSLog(@"Unable to Connect with Service: domain(%@) type(%@) name(%@) port(%i)", [sender domain], [sender type], [sender name], (int)[sender port]);
    }
}


#pragma mark - NSNetServiceBrowserDelegate

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing {

    if (![service.name isEqualToString:[UIDevice currentDevice].name]) {
        [self.services addObject:service];
    }
    
    if(!moreComing) {
        // Sort Services
        [self.services sortUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES]]];
        
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)serviceBrowser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing {
 
    [self.services removeObject:service];
    
    if(!moreComing) {
        [self.tableView reloadData];
    }
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)serviceBrowser {
    [self stopBrowsing];
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)browser didNotSearch:(NSDictionary<NSString *,NSNumber *> *)errorDict {
    [self stopBrowsing];
}


#pragma mark - GCDAsyncSocketDelegate

- (void)socket:(GCDAsyncSocket *)socket didAcceptNewSocket:(GCDAsyncSocket *)newSocket {
    NSLog(@"Accepted New Socket from %@:%hu", [newSocket connectedHost], [newSocket connectedPort]);
    
    [self stopBroadcast];
    [self.delegate controller:self didHostGameOnSocket:newSocket];
    
    [self.alertController dismissViewControllerAnimated:YES completion:nil];
    [self dismissViewControllerAnimated:YES completion:nil];

}

- (void)socket:(GCDAsyncSocket *)socket didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Socket Did Connect to Host: %@ Port: %hu", host, port);
    
    [self stopBrowsing];
    [self.delegate controller:self didJoinGameOnSocket:socket];
   
    [self dismissViewControllerAnimated:YES completion:nil];

}


- (void)socketDidDisconnect:(GCDAsyncSocket *)socket withError:(NSError *)error {

    if (self.serverSocket == socket) {
        if (error) {
            NSLog(@"Server Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
        } else {
            NSLog(@"Server Socket Disconnect.");
        }
        [socket setDelegate:nil];
        self.serverSocket = nil;
        self.serverService = nil;
    } else if (self.clientSocket == socket) {
        if (error) {
            NSLog(@"Client Socket Did Disconnect with Error %@ with User Info %@.", error, [error userInfo]);
        } else {
            NSLog(@"Client Socket Disconnect.");
        }
        [socket setDelegate:nil];
        self.clientSocket = nil;
    }
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.services.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    NSNetService *service = self.services[indexPath.row];
    
    cell.textLabel.text = service.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSNetService *service = self.services[indexPath.row];
    service.delegate = self;
    [service resolveWithTimeout:20];
}


@end
