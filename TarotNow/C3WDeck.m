//
//  C3WDeck.m
//  TarotNow
//
//  Created by Erik Petersen on 3/10/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import "C3WDeck.h"
#import "C3WCard.h"

@interface C3WDeck ()

@property (strong, nonatomic) NSMutableArray *stack;
@property (assign, nonatomic) NSInteger currentCard;

@end

@implementation C3WDeck

@synthesize stack = _stack;
@synthesize currentCard = _currentCard;

- (id)init
{
    self = [super init];
    
    if (self) {
        _stack = [[NSMutableArray alloc] init];
        _currentCard = -1;
    }
    
    return self;
}

//
// This is not an init because it is possible that this is called several times to
// load a deck from multiple sets or the same set multiple times (multi deck games)
//
- (void)loadFromDeckPropertyListFile:(NSString *)filePath
{
    NSArray *cards = [[NSDictionary dictionaryWithContentsOfFile:filePath] valueForKey:@"cards"];
    
    [cards enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self addCard:[C3WCard cardWithDictionary:obj]];
    }];
}

- (void) loadFromDeckPropertyListFiles:(NSArray *)filePaths
{
    [filePaths enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [self loadFromDeckPropertyListFile:obj];
    }];
}

- (void)addCard:(C3WCard *)card
{
    [self.stack insertObject:card atIndex:0];    
}

- (NSUInteger)numberOfCards
{
    return [self.stack count];
}

- (NSUInteger)numberOfPlayedCards
{
    return self.currentCard + 1;
}

- (NSUInteger)numberOfUnplayedCards
{
    return [self numberOfCards] - [self numberOfPlayedCards];
}

- (void)shuffleUnplayedCards
{    
    NSUInteger count = [self numberOfUnplayedCards];
    
    for (NSUInteger i = self.currentCard + 1; i < count; ++i) {
        // Randomly set orientation
        C3WCard *card = [self.stack objectAtIndex:i];
        card.orientation = (arc4random() % 2);

        // Select a random element between i and end of array to swap with.
        int nElements = count - i;
        int n = (arc4random() % nElements) + i;
        [self.stack exchangeObjectAtIndex:i withObjectAtIndex:n];
    }
}

- (void)shuffleAllCards
{
    // -1 means no current card
    self.currentCard = -1;
    [self shuffleUnplayedCards];
}

- (C3WCard *)playCard
{
    C3WCard *card = [self nextUnplayedCard];;
    
    if (card) {
        self.currentCard++;
    }
    return card;
}

- (C3WCard *)unplayCard
{
    C3WCard *card = [self previousPlayedCard];
    
    if (card) {
        self.currentCard--;
    }
    return card;
}

- (C3WCard *)nextUnplayedCard
{
    C3WCard *nextCard = nil;
    
    if ([self numberOfUnplayedCards] > 0) {
        nextCard = [self.stack objectAtIndex:(self.currentCard + 1)];
    }
    return nextCard;
}

- (C3WCard *)previousPlayedCard
{
    C3WCard *previousCard = nil;
    
    if ([self numberOfPlayedCards] > 1) {
        previousCard = [self.stack objectAtIndex:(self.currentCard - 1)];
    }
    return previousCard;
}


@end
