//
//  iGRacketViewController.h
//  iRacket
//
//  Created by nevooven on 11-4-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface iGRacketViewController : UIViewController {
    UITextView *replBuffer;
    UITextView *consoleBuffer;
}


@property (nonatomic, retain) IBOutlet UITextView *consoleBuffer;
@property (nonatomic, retain) IBOutlet UITextView *replBuffer;


@end
