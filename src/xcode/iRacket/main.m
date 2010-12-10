//
//  main.m
//  iRacket
//
//  Created by nevo on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


int main(int argc, char *argv[]) {

    //racket_main(argc, argv);
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = UIApplicationMain(argc, argv, nil, nil);
    [pool release];
    return retVal;
}
