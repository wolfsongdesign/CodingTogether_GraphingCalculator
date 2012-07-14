//
//  GraphViewController.m
//  GraphingCalculator
//
//  Created by andy on 7/12/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import "GraphViewController.h"
#import "GraphView.h"

@interface GraphViewController() <GraphViewDataSource>
@property (nonatomic, weak) IBOutlet GraphView *graphView;
@end

@implementation GraphViewController
@synthesize programDisplayOnGraphView = _programDisplayOnGraphView;

@synthesize programData = _programData;
@synthesize graphView = _graphView;

//
//
//
- (void)setProgramData:(int)programData {
    _programData = programData;
    [self.graphView setNeedsDisplay]; // any time our Model changes, redraw our View
}

//
// setGraphView
//
- (void)setGraphView:(GraphView *)graphView
{
    _graphView = graphView;
    
    // Add gestures
    // Pinch for scaling
    [self.graphView addGestureRecognizer:[[UIPinchGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pinch:)]];
    // Pan for moving graph
    [self.graphView addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(pan:)]]; 
    // Tap three times for moving origin
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self.graphView action:@selector(tap:)];
    tapRecognizer.numberOfTapsRequired = 3;
    [self.graphView addGestureRecognizer:tapRecognizer];
    
    //
    self.graphView.dataSource = self;
}

//
// dataForGraph
//
- (int)dataForGraph:(GraphView *)sender {
    return self.programData;
}

/**************/

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
}
*/

//
//
//
- (void) viewDidLoad {
    self.programDisplayOnGraphView.text = [NSString stringWithFormat:@"%d", self.programData];
}

- (void)viewDidUnload
{
    [self setGraphView:nil];
    [self setProgramDisplayOnGraphView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
