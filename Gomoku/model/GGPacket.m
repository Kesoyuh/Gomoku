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
NSString * const GGPacketKeyPiece = @"piece";

@implementation GGPacket

#pragma mark - Initializer

- (id)initWithData:(id)data type:(GGPacketType)type action:(GGPacketPiece)piece {
    self = [super init];
    
    if (self) {
        self.data = data;
        self.type = type;
        self.piece = piece;
    }
    return self;
}


#pragma mark - NSCoding Protocol

- (void)encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.data forKey:GGPacketKeyData];
    [coder encodeInteger:self.type forKey:GGPacketKeyType];
    [coder encodeInteger:self.piece forKey:GGPacketKeyPiece];
}

- (id)initWithCoder:(NSCoder *)decoder {
    self = [super init];
    
    if (self) {
        [self setData:[decoder decodeObjectForKey:GGPacketKeyData]];
        [self setType:[decoder decodeIntegerForKey:GGPacketKeyType]];
        [self setPiece:[decoder decodeIntegerForKey:GGPacketKeyPiece]];
    }
    
    return self;
}

@end
