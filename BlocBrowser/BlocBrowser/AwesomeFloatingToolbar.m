//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Kevin Thrailkill on 5/8/16.
//  Copyright © 2016 kevinthrailkill. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"


@interface AwesomeFloatingToolbar ()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longGesture;
@property (assign) int currentColorIndex;

@end

@implementation AwesomeFloatingToolbar


- (instancetype) initWithFourTitles:(NSArray *)titles {
    // First, call the superclass (UIView)'s initializer, to make sure we do all that setup first.
    self = [super init];
    
    if (self) {
        
        //set current index for color changing
        self.currentColorIndex = 1;
        
        // Save the titles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0 alpha:1],
                        [UIColor colorWithRed:222/255.0 green:165/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0 alpha:1]];
        
        NSMutableArray *labelsArray = [[NSMutableArray alloc] init];
        
        // Make the 4 labels
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [[UIButton alloc] init];
            button.alpha = 0.25;
            
            NSUInteger currentTitleIndex = [self.currentTitles indexOfObject:currentTitle]; // 0 through 3
            NSString *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.font = [UIFont systemFontOfSize:10];
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            button.backgroundColor = colorForThisLabel;
            button.titleLabel.textColor = [UIColor whiteColor];
            
            [button addTarget:self
                         action:@selector(buttonPressed:)
               forControlEvents:UIControlEventTouchUpInside];
            
            [labelsArray addObject:button];
        }
        
        self.labels = labelsArray;
        
        for (UIButton *thisButton in self.labels) {
            [self addSubview:thisButton];
        }

        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        // #1
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        // #2
        [self addGestureRecognizer:self.pinchGesture];
        
        // #1
        self.longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longFired:)];
        // #2
        [self addGestureRecognizer:self.longGesture];
        
    }
    
    return self;
}

- (void) layoutSubviews {
    // set the frames for the 4 labels
    
    for (UIButton *thisLabel in self.labels) {
        NSUInteger currentLabelIndex = [self.labels indexOfObject:thisLabel];
        
        CGFloat labelHeight = CGRectGetHeight(self.bounds) / 2;
        CGFloat labelWidth = CGRectGetWidth(self.bounds) / 2;
        CGFloat labelX = 0;
        CGFloat labelY = 0;
        
        // adjust labelX and labelY for each label
        if (currentLabelIndex < 2) {
            // 0 or 1, so on top
            labelY = 0;
        } else {
            // 2 or 3, so on bottom
            labelY = CGRectGetHeight(self.bounds) / 2;
        }
        
        if (currentLabelIndex % 2 == 0) { // is currentLabelIndex evenly divisible by 2?
            // 0 or 2, so on the left
            labelX = 0;
        } else {
            // 1 or 3, so on the right
            labelX = CGRectGetWidth(self.bounds) / 2;
        }
        
        thisLabel.frame = CGRectMake(labelX, labelY, labelWidth, labelHeight);
    }
}



#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *label = [self.labels objectAtIndex:index];
        label.userInteractionEnabled = enabled;
        label.alpha = enabled ? 1.0 : 0.25;
    }
}


- (void)buttonPressed:(UIButton *)button {
    NSLog(@"Button Pressed");
    
    
    
  //  if ([self.labels containsObject:tappedView]) { // #6
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
            [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)button).titleLabel.text];
        }
  //  }
}



#pragma mark - Gestures

- (void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) { // #3
        CGPoint location = [recognizer locationInView:self]; // #4
        UIView *tappedView = [self hitTest:location withEvent:nil]; // #5
        
        if ([self.labels containsObject:tappedView]) { // #6
            if ([self.delegate respondsToSelector:@selector(floatingToolbar:didSelectButtonWithTitle:)]) {
                [self.delegate floatingToolbar:self didSelectButtonWithTitle:((UIButton *)tappedView).titleLabel.text];
            }
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolbar:self didTryToPanWithOffset:translation];
        }
        
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGFloat scale = [recognizer scale];
        
        NSLog(@"New scale: %f", scale);
        
        if ([self.delegate respondsToSelector:@selector(floatingToolbar:didTryToPinchWithScale:)]) {
            [self.delegate floatingToolbar:self didTryToPinchWithScale:scale];
        }
       // recognizer.scale = 1;
        [recognizer setScale:1];
       // [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) longFired:(UILongPressGestureRecognizer *)recognizer {
    
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        
        // Make the 4 labels
        
        int cur = self.currentColorIndex;

        for (UIButton *label in self.labels) {
            
            NSLog(@"current index %d", cur);
            
            if(cur >= [self.labels count]){
                cur = 0;
            }
            
            UIColor *colorForThisLabel = [self.colors objectAtIndex:cur];
            label.backgroundColor = colorForThisLabel;
            cur++;
            
        }
        
        self.currentColorIndex++;
        
        if(self.currentColorIndex == [self.labels count]){
             self.currentColorIndex = 0;
        }

    }
}

@end
