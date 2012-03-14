#import <Foundation/Foundation.h>

@class C3WCard;

@interface C3WDeck : NSObject

//
// Load C3WCard's from a property list file stored in the bundle and push
// them onto the stack
//
- (void)loadFromDeckPropertyListFile:(NSString *)filePath;
- (void)loadFromDeckPropertyListFiles:(NSArray *)filePaths;

// 
// Push a C3WCard to the top of the stack
//
- (void)addCard:(C3WCard *)card;

//
// Play a card off the top of the stack
//
- (C3WCard *)playCard;
- (C3WCard *)unplayCard;

- (C3WCard *)nextUnplayedCard;
- (C3WCard *)previousPlayedCard;

//
// Count
//
- (NSUInteger)numberOfCards;
- (NSUInteger)numberOfUnplayedCards;

//
// Shuffle
//
- (void)shuffleAllCards;
- (void)shuffleUnplayedCards;

@end
