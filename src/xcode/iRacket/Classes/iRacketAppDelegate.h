//
//  iRacketAppDelegate.h
//  iRacket
//
//  Created by nevo on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class iRacketViewController;

@interface iRacketAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    iRacketViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet iRacketViewController *viewController;

@end

