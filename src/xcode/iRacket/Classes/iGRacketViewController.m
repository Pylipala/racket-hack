//
//  iGRacketViewController.m
//  iRacket
//
//  Created by nevooven on 11-4-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iGRacketViewController.h"


@implementation iGRacketViewController


@synthesize replBuffer;


- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"iGRacket";
        self.navigationItem.rightBarButtonItem =
        [[[UIBarButtonItem alloc]
          initWithTitle:@"R"
                  style:UIBarButtonItemStyleDone
                 target:self
                 action:@selector(eval:)] autorelease];
    }
    return self;
}

- (void)dealloc
{
    self.replBuffer = nil;
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


#pragma mark - REPL

- (void)eval:(id)sender
{
    
}

@end
