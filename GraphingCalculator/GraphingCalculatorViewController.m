//
//  GraphingCalculatorViewController.m
//  GraphingCalculator
//
//  Created by andy on 7/11/12.
//  Copyright (c) 2012 Wolfsong, LLC. All rights reserved.
//

#import "GraphingCalculatorViewController.h"
#import "CalculatorBrain.h"
#import "GraphViewController.h"


@interface GraphingCalculatorViewController()
@property (weak, nonatomic) IBOutlet UILabel *display;
@property (weak, nonatomic) IBOutlet UILabel *programDescriptionLabel;
@property (nonatomic) BOOL userIsInTheMiddleOfEnteringANumber;
@property (nonatomic) BOOL userEnteredADecimal;
@property (strong, nonatomic) CalculatorBrain *brain;
@end


@implementation GraphingCalculatorViewController

@synthesize display = _display;
@synthesize programDescriptionLabel = _programDescriptionLabel;
@synthesize userIsInTheMiddleOfEnteringANumber = _userIsInTheMiddleOfEnteringANumber;
@synthesize userEnteredADecimal = _userEnteredADecimal;
@synthesize brain = _brain;

//
// Lazy instantiation of Array 
//
- (CalculatorBrain *)brain {
    if (!_brain) {
        _brain = [[CalculatorBrain alloc] init];
    }
    return _brain;
}

//
// digit Key Pressed
//
- (IBAction)digitPressed:(UIButton *)sender {
    // FIXME using currentTitle of button instead of using localization
    NSString *digit = sender.currentTitle;
    
    // Add digits to display string
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingFormat:digit];
    } else {
        self.display.text = digit;
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
}

//
// clear Key Pressed
//
- (IBAction)clearPressed {
    // Reset BOOLs
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userEnteredADecimal = NO;
    // Clear display(s)
    self.display.text = @"0"; 
    self.programDescriptionLabel.text = @" ";
    // Clear stack
    [self.brain performOperation: @"CLEAR"];
}

//
// enter Key Pressed
//
- (IBAction)enterPressed {    
    NSString *displayString = self.display.text;
    
    // Catch corner case if user presses "." then Enter
    if ([displayString isEqualToString:@"."]) return;
    
    // Set BOOLs
    self.userIsInTheMiddleOfEnteringANumber = NO;
    self.userEnteredADecimal = NO;
    
    // Push operand on stack
    [self.brain pushOperand:[displayString doubleValue]];
    // FIXME
    // Set label
    self.programDescriptionLabel.text = [[CalculatorBrain class] descriptionOfProgram:self.brain.program];
}

//
// plus/minus Key Pressed
//
- (IBAction)plusMinusPressed {
    NSString *displayString = self.display.text;
    
    // Add or remove leading "-" from string 
    if ( [displayString compare:@"-" options:0 range:NSMakeRange(0, 1)] == NSOrderedSame)
    {
        // Return substring after the "-" 
        self.display.text = [displayString substringFromIndex:(1)];
    } else {
        // Prepend "-" to displayString 
        self.display.text = [NSString stringWithFormat:@"-%@", displayString];
    }
}

//
// decimal Key Pressed
//
- (IBAction)decimalPressed {
    // Check if decimal has already been pressed
    if (self.userEnteredADecimal) return;
    // Add decimal to display string
    if (self.userIsInTheMiddleOfEnteringANumber) {
        self.display.text = [self.display.text stringByAppendingFormat:@"."];
    } else {
        self.display.text = @".";
        self.userIsInTheMiddleOfEnteringANumber = YES;
    }
    // Set userEnteredADecimal
    self.userEnteredADecimal = YES;
}

//
// backspace Key Pressed
//
- (IBAction)backspacePressed {
    NSString *displayString = self.display.text;
    NSUInteger lengthOfString = displayString.length;
    
    // Probably too verbose due to corner cases
    if (lengthOfString > 1) {
        // Check display for length == 2 
        // Set to '0' if display is a minus sign with number/decimal
        if (lengthOfString == 2) {
            if ( [displayString compare:@"-" options:0 range:NSMakeRange(0, 1)] == NSOrderedSame) {
                // Display = "0"
                self.display.text = @"0";
                self.userIsInTheMiddleOfEnteringANumber = NO;
                self.userEnteredADecimal = NO;
            } else {
                self.display.text = [displayString substringToIndex:(lengthOfString -1)];
            }
        } else {
            // Check to see if removing a decimal
            if ([displayString compare:@"." options:0 range:NSMakeRange(lengthOfString-1, 1)] == NSOrderedSame) {
                // If removed a decimal, set BOOL to NO
                self.userEnteredADecimal = NO;
            }
            // Remove one trailing character from string
            self.display.text = [displayString substringToIndex:(lengthOfString -1)];
        }
    } else {
        // lengthOfString == 0 or 1, set display to '0'
        self.display.text = @"0";
        self.userIsInTheMiddleOfEnteringANumber = NO;
        self.userEnteredADecimal = NO;
        
        // Pop last object off stack
        [self.brain popOffStack];
        // Recalculate displays
        double result = [CalculatorBrain runProgram:self.brain.program];
        self.display.text = [NSString stringWithFormat:@"%g", result];
        self.programDescriptionLabel.text = [[CalculatorBrain class] descriptionOfProgram:self.brain.program];
    }
}

//
// variable Key Pressed
//
- (IBAction)variablePressed:(UIButton *)sender {
    NSString *variable = sender.currentTitle;
    
    // Press Enter for the user
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    [self.brain pushVariable:variable];
    self.display.text = variable;
}

//
// operation Key Pressed
//
- (IBAction)operationPressed:(id)sender {    
    NSString *operation = [sender currentTitle];
    
    // If user presses a number then an operation, press Enter for the user
    if (self.userIsInTheMiddleOfEnteringANumber) {
        [self enterPressed];
    }
    
    // Reset userEnteredADecimal
    self.userEnteredADecimal = NO;
    //
    double result = [self.brain performOperation:operation];
    
    // Set programDescription label
    self.programDescriptionLabel.text = [CalculatorBrain descriptionOfProgram:self.brain.program];
    self.display.text = [NSString stringWithFormat:@"%g", result];
}

//
// prepareForSegue
//
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"ShowGraph"]) {
        [segue.destinationViewController setProgramData:[self.display.text intValue]];
    }
}

//
// graphKeyPressed
//
- (void)setAndShowGraph:(id)programData {
    [self performSegueWithIdentifier:@"ShowGraph" sender:self];
/*    self.programData = programData;
    // if in split view
    if ([self splitViewHappinessViewController]) {
        // just set happiness in detail
        [self splitViewHappinessViewController].happiness = programData;  
    } else {
        [self performSegueWithIdentifier:@"ShowGraph" sender:self];
    }
 */
}


//
// variablesDisplayStringFromVariablesUsedSet
//
- (NSString *)variablesDisplayStringFromVariablesUsedSet:(NSSet *)variablesUsedSet withDictionary:(NSDictionary *)dictionary {
    // Array of key value pairs
    NSMutableArray *variablesArray = [[NSMutableArray alloc] init];
    // Use enumerator to iterate over Set
    NSEnumerator *e = [variablesUsedSet objectEnumerator];
    id object;
    while (object = [e nextObject]) {
        // Get key value
        NSString *val = [dictionary valueForKey:object];
        // Add key value to array if it exists
        if (val) {
            [variablesArray addObject:[NSString stringWithFormat:@"%@ = %@", object, val]];
        }
    }
    // Seperate programs by comma
    if (variablesArray.count > 1) {
        return [variablesArray componentsJoinedByString:@", "];
    } else {
        return variablesArray.lastObject; 
    }
}



- (void)viewDidUnload {
    [self setDisplay:nil];
    [self setProgramDescriptionLabel:nil];
    [super viewDidUnload];
}
@end

