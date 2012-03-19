//
//  C3WCard.h
//  TarotNow
//
//  Created by Erik Petersen on 3/10/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import <Foundation/Foundation.h>

enum {
    C3WCardOrientationUpright = 0,
    C3WCardOrientationReversed,
};
typedef NSUInteger C3WCardOrientation;

@interface C3WCard : NSObject

@property (strong, nonatomic) NSString              *description;
@property (strong, nonatomic) NSString              *meaning;
@property (strong, nonatomic) NSString              *reverse;
@property (strong, nonatomic) NSString              *suit;
@property (strong, nonatomic) NSString              *color;
@property (strong, nonatomic) UIImage               *cardImage;
@property (assign, nonatomic) C3WCardOrientation    orientation;

+ (id)cardWithDictionary:(NSDictionary *)dict;

- (UIImageOrientation)cardImageOrientation;

@end
