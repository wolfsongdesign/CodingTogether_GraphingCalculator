//
//  GraphView.h
//  GraphingCalculator
//
//  Created by andy on 7/11/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GraphView;

@protocol GraphViewDataSource
- (int)dataForGraph:(GraphView *)sender;
@end

@interface GraphView : UIView

@property (nonatomic) CGFloat scale;
@property (nonatomic) CGFloat offsetx;
@property (nonatomic) CGFloat offsety;
@property (nonatomic,assign) CGPoint midPoint;
// Pinch for scaling graph
- (void)pinch:(UIPinchGestureRecognizer *)gesture;
// Pan for moving graph
- (void)pan:(UIPanGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
