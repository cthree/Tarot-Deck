//
//  C3WCardViewController.m
//  TarotNow
//
//  Created by Erik Petersen on 3/10/12.
//  Copyright (c) 2012 4MMedia. All rights reserved.
//

#import "C3WCardViewController.h"

#import "C3WDeck.h"
#import "C3WCard.h"

@interface C3WCardViewController ()

@property (weak, nonatomic)     IBOutlet UIImageView    *cardImageView;
@property (weak, nonatomic)     IBOutlet UIImageView    *nextCardImageView;
@property (weak, nonatomic)     IBOutlet UILabel        *meaningLabel;
@property (weak, nonatomic)     IBOutlet UIView         *infoPanelView;
@property (weak, nonatomic)     IBOutlet UILabel        *cardName;
@property (weak, nonatomic)     IBOutlet UIButton       *infoButton;

@property (strong, nonatomic)   C3WDeck                 *deck;
@property (assign, nonatomic)   BOOL                    infoVisible;

@end

@implementation C3WCardViewController

@synthesize cardImageView   = _cardImageView;
@synthesize nextCardImageView = _nextCardImageView;
@synthesize meaningLabel    = _meaningLabel;
@synthesize infoPanelView   = _infoPanelView;
@synthesize cardName        = _cardName;
@synthesize infoButton = _infoButton;
@synthesize deck            = _deck;
@synthesize infoVisible     = _infoVisible;

#pragma mark - Lifecycle Events

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self configure];
    [self.deck shuffleAllCards];
    [self turnTopCard];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidUnload
{
    [self setCardImageView:nil];
    [self setMeaningLabel:nil];
    [self setDeck:nil];
    [self setInfoPanelView:nil];
    [self setCardName:nil];
    [self setNextCardImageView:nil];
    [self setInfoButton:nil];
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// Activates shake gesture recognition feature
- (BOOL)canBecomeFirstResponder
{
    return YES;
}

#pragma mark - View Control

- (void)configure
{    
    self.deck = [[C3WDeck alloc] init];

    // Load the cards into the deck
    NSArray *deckFiles = [NSArray arrayWithObjects:
                          [[NSBundle mainBundle] pathForResource:@"RWSMajor" ofType:@"plist"],
                          [[NSBundle mainBundle] pathForResource:@"RWSMinor" ofType:@"plist"],
                          nil];
    [self.deck loadFromDeckPropertyListFiles:deckFiles];

    // Add Swipe *UP* recogniser (play a new card)
    UISwipeGestureRecognizer *swipeUpGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedUp)];
    swipeUpGestureRecogniser.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUpGestureRecogniser];
    
    // Add Swipe *DOWN* recogniser (unplay last card)
    UISwipeGestureRecognizer *swipeDownGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipedDown)];
    swipeDownGestureRecogniser.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGestureRecogniser];
    
    // Add double tap recogniser (reveal)
    UITapGestureRecognizer *doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(doubleTapped:)];
    doubleTapRecogniser.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapRecogniser];
    
    // Add single tap recogniser (quick reveal)
    UITapGestureRecognizer *singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                          action:@selector(tapped:)];
    [singleTapRecogniser requireGestureRecognizerToFail:doubleTapRecogniser];
    singleTapRecogniser.delegate = self;
    [self.view addGestureRecognizer:singleTapRecogniser];
    
    // Set the info panel to be invisible
    [self hideInfo];
}

- (void)toggleInfoVisibleWithAnimation
{
    if (self.infoVisible) {
        [UIView animateWithDuration:0.5 animations:^{
            self.infoPanelView.alpha = 0.0;
        }];
        self.infoVisible = NO;
    }
    else {
        [UIView animateWithDuration:0.5 animations:^{
            self.infoPanelView.alpha = 0.9;
        }];
        self.infoVisible = YES;
    }
}

- (void)hideInfo
{
    self.infoPanelView.alpha = 0.0;
    self.infoVisible = NO;
}

- (void)displayCard:(C3WCard *)card withAnimation:(UIViewAnimationOptions)animationOptions
{
    // Hide the info overlay anytime the card changes
    [self hideInfo];
    
    if (card.orientation == C3WCardOrientationUpright) {
        self.cardName.text      = card.description;
        self.meaningLabel.text  = card.meaning;
    }
    else {
        self.cardName.text      = [NSString stringWithFormat:@"%@ (Reversed)", card.description];
        self.meaningLabel.text  = card.reverse;
    }

    [UIView transitionWithView:self.view 
                      duration:0.5 
                       options:animationOptions
                    animations:^{
                        self.cardImageView.hidden = YES;
                        self.nextCardImageView.hidden = NO;
                    } completion:^(BOOL finished) {
                        UIImageView *tmp = self.cardImageView;
                        self.cardImageView = self.nextCardImageView;
                        self.nextCardImageView = tmp;
                    }];
}

- (void) displayCard:(C3WCard *)card
{
    [self displayCard:card
        withAnimation:UIViewAnimationOptionTransitionNone];
}

- (void)turnTopCard
{
    C3WCard *nextCard = [self.deck playCard];
    
    if (nextCard) {
        UIImageOrientation orientation = nextCard.orientation == C3WCardOrientationUpright ? UIImageOrientationUp : UIImageOrientationDown;
        
        self.nextCardImageView.image = [UIImage imageWithCGImage:nextCard.cardImage.CGImage 
                                                           scale:1.0 
                                                     orientation:orientation];

        [self displayCard:nextCard 
            withAnimation:UIViewAnimationOptionTransitionFlipFromTop];
    }    
}

- (void)unturnTopCard
{
    C3WCard *nextCard = [self.deck unplayCard];
    
    if (nextCard) {
        UIImageOrientation orientation = nextCard.orientation == C3WCardOrientationUpright ? UIImageOrientationUp : UIImageOrientationDown;
        
        self.nextCardImageView.image = [UIImage imageWithCGImage:nextCard.cardImage.CGImage 
                                                           scale:1.0 
                                                     orientation:orientation];
        
        [self displayCard:nextCard 
            withAnimation:UIViewAnimationOptionTransitionFlipFromBottom];
    }    
}

#pragma mark - Gesture Recognisers

// Play a new card
- (void)swipedUp
{
    [self turnTopCard];
}

// Unplay the last card
- (void)swipedDown
{
    [self unturnTopCard];
}

- (void)tapped:(UIGestureRecognizer *)sender
{
    [self toggleInfoVisibleWithAnimation];
}

- (void)doubleTapped:(UIGestureRecognizer *)sender
{
    [self.deck shuffleAllCards];
    [self turnTopCard];
}

// Prevent taps around the info button from being recognised as a general tap
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)sender
{
    CGPoint point = [sender locationInView:self.infoButton];
    if (point.x > -30.0 && point.y > -30.0) {
        return NO;
    }
    return YES;
    
}

- (void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // Ignore
}

- (void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    // Ignore
}

// Shake to shuffle
- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event
{
    [self.deck shuffleAllCards];
    [self turnTopCard];
}

#pragma mark - Flipside View

- (void)flipsideViewControllerDidFinish:(C3WFlipsideViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showAlternate"]) {
        [[segue destinationViewController] setDelegate:self];
    }
}

@end
