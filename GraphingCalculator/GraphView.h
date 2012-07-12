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
- (void)pinch:(UIPinchGestureRecognizer *)gesture;

@property (nonatomic, weak) IBOutlet id <GraphViewDataSource> dataSource;

@end
