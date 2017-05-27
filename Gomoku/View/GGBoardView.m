//
//  Board.m
//  Gomoku
//
//  Created by Changchang on 27/5/17.
//  Copyright © 2017 University of Melbourne. All rights reserved.
//

#import "GGBoardView.h"

@interface GGBoardView () {
    CGFloat margin;
    CGFloat interval;
}

@end

@implementation GGBoardView

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    [self addGestureRecognizer: tapGestureRecognizer];
    return self;
}

- (void)handleTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    CGPoint location = [tapGestureRecognizer locationInView:self];
    int row = (int)((location.y - margin) / interval);
    double modY = (location.y - margin) / interval - row;
    if(modY > 0.5) {
        row++;
    }
    
    int column = (int)((location.x - margin) / interval);
    double modX = (location.x - margin) / interval - column;
    if(modX > 0.5) {
        column++;
    }
    NSLog(@"%d, %d", column, row);
    
    
}

- (void)drawRect:(CGRect)rect {
    margin = 15;
    interval =(self.bounds.size.width - margin * 2) / 14;

    
    CGFloat borderLineWidth = 2;
    CGFloat insideLineWidth = 1;
    
    // Draw lines on the board
    for (int i = 0; i < 15; i++) {
        UIBezierPath *horizontalLine = [[UIBezierPath alloc] init];
        UIBezierPath *verticalLine = [[UIBezierPath alloc] init];
        
        if (i == 0 || i == 14) {
            [horizontalLine moveToPoint:CGPointMake(margin - 1, interval * i + margin)];
            [verticalLine moveToPoint:CGPointMake(interval * i + margin, margin)];
            
            [horizontalLine addLineToPoint:CGPointMake(margin + interval * 14 + 1, interval * i + margin)];
            [verticalLine addLineToPoint:CGPointMake(interval * i + margin, margin + interval * 14)];
            
            horizontalLine.lineWidth = borderLineWidth;
            verticalLine.lineWidth  = borderLineWidth;
        } else {
            [horizontalLine moveToPoint:CGPointMake(margin, interval * i + margin)];
            [verticalLine moveToPoint:CGPointMake(interval * i + margin, margin)];
            
            [horizontalLine addLineToPoint:CGPointMake(margin + interval * 14, interval * i + margin)];
            [verticalLine addLineToPoint:CGPointMake(interval * i + margin, margin + interval * 14)];
            
            horizontalLine.lineWidth = insideLineWidth;
            verticalLine.lineWidth  = insideLineWidth;
        }
        
        [[UIColor blackColor] setStroke];
        
        [horizontalLine stroke];
        [verticalLine stroke];
    }
    
    // Draw 5 dots on the board
    CGFloat dotRadius = 3;
    int dotList[5][2] = {{3, 3}, {3, 11}, {7, 7}, {11, 3}, {11, 11}};
    
    for (int i = 0; i < 5; i++) {
        CGFloat centerX = margin + dotList[i][0] * interval;
        CGFloat centerY = margin + dotList[i][1] * interval;
        CGRect rect = CGRectMake(centerX - dotRadius, centerY - dotRadius, dotRadius * 2, dotRadius * 2);
        UIBezierPath *dot = [UIBezierPath bezierPathWithOvalInRect:rect];
        [[UIColor blackColor] setFill];
        [dot fill];
    }
}
@end
