//
//  GGPacket.h
//  Gomoku
//
//  Created by Changchang on 12/7/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const GGPacketKeyData;
extern NSString * const GGPacketKeyType;
extern NSString * const GGPacketKeyPiece;

typedef NS_ENUM(NSInteger, GGPacketType) {
    GGPacketTypeUnknown,
    GGPacketTypeMove
};

typedef NS_ENUM(NSInteger, GGPacketPiece) {
    GGPacketPieceBlack,
    GGPacketPieceWhite,
    GGPacketPieceUnknown
};

@interface GGPacket : NSObject

@property (strong, nonatomic) id data;
@property (assign, nonatomic) GGPacketType type;
@property (assign, nonatomic) GGPacketPiece piece;

- (id)initWithData:(id)data type:(GGPacketType)type action:(GGPacketPiece)piece;

@end
