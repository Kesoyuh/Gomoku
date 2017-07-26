//
//  GGPacket.m
//  Gomoku
//
//  Created by Changchang on 12/7/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGPacket.h"

NSString * const GGPacketKeyData = @"data";
NSString * const GGPacketKeyType = @"type";
NSString * const GGPacketKeyAction = @"piece";

@implementation GGPacket

#pragma mark - Initializer

- (id)initWithData:(id)data type:(GGPacketType)type action:(GGPacketAction)action {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.action = action;
    }
    return self;
}


#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:GGPacketKeyData];
    [coder encodeInteger:self.type forKey:GGPacketKeyType];
    [coder encodeInteger:self.action forKey:GGPacketKeyAction];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:GGPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:GGPacketKeyType]];
        [self setAction:[decoder decodeIntegerForKey:GGPacketKeyAction]];
    }
    
    return self;
}

@end
