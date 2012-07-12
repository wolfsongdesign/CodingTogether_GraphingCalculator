//
//  GraphView.m
//  GraphingCalculator
//
//  Created by andy on 7/11/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import "GraphView.h"
#import "AxesDrawer.h"

@implementation GraphView

@synthesize dataSource = _dataSource;
@synthesize scale = _scale;

@synthesize offsetx=_offsetx;
@synthesize offsety=_offsety;
@synthesize midPoint=_midPoint;

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
        // Adjust scale
        self.scale *= gesture.scale; 
        gesture.scale = 1;
    }
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint tapPoint = [gesture locationInView:gesture.view];
        //NSLog(@"%g, %g", tapPoint.x, tapPoint.y);
        self.midPoint=tapPoint;
        [self setNeedsDisplay];
    }
}

- (void)pan:(UIPanGestureRecognizer *)gesture
{
    if ((gesture.state == UIGestureRecognizerStateChanged) ||
        (gesture.state == UIGestureRecognizerStateEnded)) {
        CGPoint translation = [gesture translationInView:self];
        // NSLog(@"%g, %g", translation.x, translation.y);
        self.offsetx -= -translation.x / 2;
        self.offsety -= -translation.y / 2;
        [self setNeedsDisplay];
        
        // reset
        [gesture setTranslation:CGPointZero inView:self];
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
//
//
- (void)drawCircleAtPoint:(CGPoint)p withRadius:(CGFloat)radius inContext:(CGContextRef)context
{
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    CGContextAddArc(context, p.x, p.y, radius, 0, 2*M_PI, YES); // 360 degree (0 to 2pi) arc
    CGContextStrokePath(context);
    UIGraphicsPopContext();
}

//
// drawTestData
//
- (void)drawTestData:(CGPoint)p inContext:(CGContextRef)context {
    UIGraphicsPushContext(context);
    CGContextBeginPath(context);
    // Move and draw lines
    CGContextMoveToPoint(context, self.bounds.size.width / 2, self.bounds.size.height /2);
    CGContextAddLineToPoint(context, p.x, p.y);
    // Lines don't show up until they have a width/color
    // Set Line width and color
    CGContextSetLineWidth(context, 1.0);
    [[UIColor redColor] setStroke];

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
    
    // Drawing code
    CGRect baseRect = self.bounds;
    baseRect.origin.x += self.offsetx;
    baseRect.origin.y += self.offsety;
    
    CGFloat size = self.bounds.size.width / 2;
    if (self.bounds.size.height < self.bounds.size.width) size = self.bounds.size.height / 2;
    size *= self.scale; // scale is percentage of full view size
    
    // Set Line width and color
    CGContextSetLineWidth(context, 2.0);
    [[UIColor grayColor] setStroke];
    
    // Draw X and Y Axis
    [self drawXYAxes:midPoint inContext:context];
    [AxesDrawer drawAxesInRect:baseRect originAtPoint:self.midPoint scale:self.scale];

    // Test data
    int foo = [self.dataSource dataForGraph:self];
    CGPoint testPoint;
    testPoint.x = foo;
    testPoint.y = foo;
    [self drawTestData:testPoint inContext:context];

    // Draw face
    [self drawCircleAtPoint:midPoint withRadius:size inContext:context]; // head
    
#define EYE_H 0.35
#define EYE_V 0.35
#define EYE_RADIUS 0.10
    
    CGPoint eyePoint;
    eyePoint.x = midPoint.x - size * EYE_H;
    eyePoint.y = midPoint.y - size * EYE_V;
    
    [self drawCircleAtPoint:eyePoint withRadius:size * EYE_RADIUS inContext:context]; // left eye
    eyePoint.x += size * EYE_H * 2;
    [self drawCircleAtPoint:eyePoint withRadius:size * EYE_RADIUS inContext:context]; // right eye
    
#define MOUTH_H 0.45
#define MOUTH_V 0.40
#define MOUTH_SMILE 0.25
    
    CGPoint mouthStart;
    mouthStart.x = midPoint.x - MOUTH_H * size;
    mouthStart.y = midPoint.y + MOUTH_V * size;
    CGPoint mouthEnd = mouthStart;
    mouthEnd.x += MOUTH_H * size * 2;
    CGPoint mouthCP1 = mouthStart;
    mouthCP1.x += MOUTH_H * size * 2/3;
    CGPoint mouthCP2 = mouthEnd;
    mouthCP2.x -= MOUTH_H * size * 2/3;
    
    float smile = 1.0; // this should be delegated! it's our View's data!
    
    CGFloat smileOffset = MOUTH_SMILE * size * smile;
    mouthCP1.y += smileOffset;
    mouthCP2.y += smileOffset;
    
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, mouthStart.x, mouthStart.y);
    CGContextAddCurveToPoint(context, mouthCP1.x, mouthCP2.y, mouthCP2.x, mouthCP2.y, mouthEnd.x, mouthEnd.y); // bezier curve
    CGContextStrokePath(context);
}

/******************************************/

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
