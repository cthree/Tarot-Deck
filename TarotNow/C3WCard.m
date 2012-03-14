//
//  C3WCard.m
//  TarotNow
//
//  Created by Erik Petersen on 3/10/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import "C3WCard.h"

@interface C3WCard ()

@property (strong, nonatomic) NSString *imageName;

@end

@implementation C3WCard

@synthesize description = _desciption;
@synthesize meaning = _meaning;
@synthesize reverse = _reverse;
@synthesize imageName = _imageName;
@synthesize suit = _suit;
@synthesize color = _color;
@synthesize orientation = _orientation;
@synthesize cardImage = _cardImage;

+ (id)cardWithDictionary:(NSDictionary *)dict
{
    C3WCard *newCard     = [[C3WCard alloc] init];
    
    newCard.description  = [dict valueForKey:@"description"];
    newCard.meaning      = [dict valueForKey:@"meaning"];
    newCard.reverse      = [dict valueForKey:@"reverse"];
    newCard.imageName    = [dict valueForKey:@"imageName"];
    newCard.suit         = [dict valueForKey:@"suit"];
    newCard.color        = [dict valueForKey:@"color"];
    newCard.orientation  = C3WCardOrientationUpright;
    
    return newCard;
}

- (UIImage *)cardImage
{
    if (_cardImage == nil && self.imageName != nil) {
        NSString *imagePath = [[NSBundle mainBundle] pathForResource:self.imageName ofType:@"jpg"];
        _cardImage = [[UIImage alloc] initWithContentsOfFile:imagePath];
    }
    return _cardImage;
}

- (BOOL)isReversed
{
    return (self.orientation == C3WCardOrientationReversed);
}


@end
