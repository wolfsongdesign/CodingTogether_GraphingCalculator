//
//  GraphViewController.h
//  GraphingCalculator
//
//  Created by andy on 7/12/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GraphViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *programDisplayOnGraphView;

// Program data
@property (nonatomic) int programData;

@end
