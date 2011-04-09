//
//  main.m
//  iRacket
//
//  Created by nevo on 10-10-24.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#define MZ_PRECISE_GC


#import <UIKit/UIKit.h>
#import "scheme.h"


static int racket_main(Scheme_Env *e, int argc, char *argv[])
{
    Scheme_Config *config = NULL;


    MZ_GC_DECL_REG(1);
    MZ_GC_VAR_IN_REG(0, config);
    MZ_GC_REG();
    
    config = scheme_current_config();


    /*
     * Set PATH variable in case find-executable-path will need it if exec_cmd
     * is in relative path.
     */
    //setenv("PATH", [[[NSBundle mainBundle] bundlePath] UTF8String], 1);
    
    // we'll need to set Racket collect path
    Scheme_Object *coldir =
        scheme_make_path([[[[NSBundle mainBundle] bundlePath]
                             stringByAppendingString:@"/icollects"] UTF8String]);
    scheme_set_collects_path(coldir);

    scheme_init_collection_paths(e, scheme_null);
    
#if TARGET_IPHONE_SIMULATOR
    scheme_set_exec_cmd((char *)[[[[NSBundle mainBundle] bundlePath]
                           stringByAppendingString:@"/iRacketSim"] UTF8String]);    
#else
    scheme_set_exec_cmd("iRacket");
#endif

    // getcwd in iOS returns "/", so we'll need to set our own cwd
    Scheme_Object *cwd =
    scheme_make_path([[[NSBundle mainBundle] bundlePath] UTF8String]);
    scheme_set_param(config, MZCONFIG_CURRENT_DIRECTORY, cwd);
    scheme_set_original_dir(cwd);

    MZ_GC_UNREG();
    return UIApplicationMain(argc, argv, nil, nil);
}


int main(int argc, char *argv[]) {
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    int retVal = scheme_main_setup(1, racket_main, argc, argv);
    [pool release];
    return retVal;
}

