//
//  GraphView.m
//  GraphingCalculator
//
//  Created by andy on 7/11/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import "GraphView.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;

#define DEFAULT_SCALE 0.90

- (CGFloat)scale {
    if (!_scale) {
        return DEFAULT_SCALE; // don't allow zero scale
    } else {
        return _scale;
    }
}

- (void)setScale:(CGFloat)scale {
    if (scale != _scale) {
        _scale = scale;
        [self setNeedsDisplay]; // any time our scale changes, call for redraw
    }
}

- (void)pinch:(UIPinchGestureRecognizer *)gesture {
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        self.scale *= gesture.scale; // adjust our scale
        gesture.scale = 1;           // reset gestures scale to 1 (so future changes are incremental, not cumulative)
    }
}

- (void)setup {
    self.contentMode = UIViewContentModeRedraw; // if our bounds changes, redraw ourselves
}

- (void)awakeFromNib {
    [self setup]; // get initialized when we come out of a storyboard
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setup]; // get initialized if someone uses alloc/initWithFrame: to create us
    }
    return self;
}

/******************************************/
//
//  DRAWING METHODS
//
/******************************************/

//
// drawXYAxes
//
- (void)drawXYAxes:(CGPoint)p inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    // Move and draw lines
    CGContextMoveToPoint(context, p.x, 0);
    CGContextAddLineToPoint(context, p.x, self.bounds.size.height);    
    CGContextMoveToPoint(context, 0, p.y);
    CGContextAddLineToPoint(context, self.bounds.size.width, p.y);
    // Lines don't show up until they have a width/color
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

//
// drawRect
//
- (void)drawRect:(CGRect)rect {
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Compute midpoint in our coordinate system
    CGPoint midPoint; 
    midPoint.x = self.bounds.origin.x + self.bounds.size.width/2;
    midPoint.y = self.bounds.origin.y + self.bounds.size.height/2;
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale; // scale is percentage of full view size
    
    // Set Line width and color
    CGContextSetLineWidth(context, 2.0);
    [[UIColor grayColor] setStroke];
    
    // Draw X and Y Axis
    [self drawXYAxes:midPoint inContext:context];

}

/******************************************/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
