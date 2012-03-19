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

@synthesize cardImageView       = _cardImageView;
@synthesize nextCardImageView   = _nextCardImageView;
@synthesize meaningLabel        = _meaningLabel;
@synthesize infoPanelView       = _infoPanelView;
@synthesize cardName            = _cardName;
@synthesize infoButton          = _infoButton;
@synthesize deck                = _deck;
@synthesize infoVisible         = _infoVisible;

#pragma mark - Lifecycle

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

    // Configure and play
    [self configure];
    [self shuffleAndPlay];

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

// Setup the working deck of cards and the UI handlers
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
    UISwipeGestureRecognizer *swipeUpGestureRecogniser;
    swipeUpGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                         action:@selector(swipedUp)];
    swipeUpGestureRecogniser.direction = UISwipeGestureRecognizerDirectionUp;
    [self.view addGestureRecognizer:swipeUpGestureRecogniser];
    
    // Add Swipe *DOWN* recogniser (unplay last card)
    UISwipeGestureRecognizer *swipeDownGestureRecogniser;
    swipeDownGestureRecogniser = [[UISwipeGestureRecognizer alloc] initWithTarget:self 
                                                                           action:@selector(swipedDown)];
    swipeDownGestureRecogniser.direction = UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeDownGestureRecogniser];
    
    // Add double tap recogniser (reveal)
    UITapGestureRecognizer *doubleTapRecogniser;
    doubleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(doubleTapped:)];
    doubleTapRecogniser.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapRecogniser];
    
    // Add single tap recogniser (quick reveal)
    UITapGestureRecognizer *singleTapRecogniser;
    singleTapRecogniser = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                  action:@selector(tapped:)];
    singleTapRecogniser.delegate = self;
    [singleTapRecogniser requireGestureRecognizerToFail:doubleTapRecogniser];
    [self.view addGestureRecognizer:singleTapRecogniser];
    
    // Set the info panel to be invisible
    [self hideInfo];
}

// Toggle info panel visibility with animation
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

// Hide the card info if visible without animation
- (void)hideInfo
{
    self.infoPanelView.alpha = 0.0;
    self.infoVisible = NO;
}

// Main card display method. Display card with the animationOptions animation sequence
- (void)displayCard:(C3WCard *)card withAnimation:(UIViewAnimationOptions)animationOptions
{
    if (card) {
        // Hide the info overlay when the card changes
        [self hideInfo];
        
        // Set Title and meaning text for new card
        if (card.cardImageOrientation == UIImageOrientationUp) {
            self.cardName.text      = card.description;
            self.meaningLabel.text  = card.meaning;
        }
        else {
            self.cardName.text      = [NSString stringWithFormat:@"%@ (Reversed)", card.description];
            self.meaningLabel.text  = card.reverse;
        }
        
        // Set new card image
        self.nextCardImageView.image = [UIImage imageWithCGImage:card.cardImage.CGImage 
                                                           scale:1.0 
                                                     orientation:card.cardImageOrientation];
        
        // Transtion from current card image to new card image with animation
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
}

// Display card without animation
- (void) displayCard:(C3WCard *)card
{
    [self displayCard:card withAnimation:UIViewAnimationOptionTransitionNone];
}

// Display the next unturned card in the deck
- (void)displayNextCard
{
    [self displayCard:[self.deck playCard] 
        withAnimation:UIViewAnimationOptionTransitionFlipFromTop];
}

// Redisplay the previously turned card
- (void)displayPreviousCard
{
    [self displayCard:[self.deck unplayCard] 
        withAnimation:UIViewAnimationOptionTransitionFlipFromBottom];
}

// Shuffle the deck and turn the top card
- (void)shuffleAndPlay
{
    [self.deck shuffleAllCards];
    [self displayNextCard];
}

#pragma mark - Gesture Recognisers

// show the next card
- (void)swipedUp
{
    [self displayNextCard];
}

// show the previous card
- (void)swipedDown
{
    [self displayPreviousCard];
}

// tap to toggle title/meaning info panel
- (void)tapped:(UIGestureRecognizer *)sender
{
    [self toggleInfoVisibleWithAnimation];
}

// double tap to shuffle
- (void)doubleTapped:(UIGestureRecognizer *)sender
{
    [self shuffleAndPlay];
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
    [self shuffleAndPlay];
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
