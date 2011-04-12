//
//  iGRacketViewController.m
//  iRacket
//
//  Created by nevooven on 11-4-9.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#define MZ_PRECISE_GC

#include "scheme.h"
#import "iGRacketViewController.h"


@implementation iGRacketViewController


@synthesize consoleBuffer;
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

#pragma mark - Racket output port
static intptr_t
igracket_write_bytes(Scheme_Output_Port* port, const char* buffer,
                     intptr_t offset, intptr_t size, int rarely_block,
                     int enable_block)
{
    NSLog(@"write %d bytes in offset %d (%d %d)", size, offset, rarely_block,
          enable_block);
    if (size) {
        NSString *s = [[NSString alloc] initWithBytes:buffer + offset
                                               length:size
                                             encoding:NSUTF8StringEncoding];
        iGRacketViewController *this = SCHEME_OUTPORT_VAL(port);
        this.consoleBuffer.text = [this.consoleBuffer.text
                                      stringByAppendingFormat:@"%@", s];
    }
    return size;
}

static int
igracket_char_ready(Scheme_Output_Port* port)
{
    NSLog(@"char ready called");
    return 1;
}

static void
igracket_close(Scheme_Output_Port* port)
{
    NSLog(@"close called");
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    Scheme_Object *type;
    Scheme_Object *op = NULL;
    Scheme_Object *name = NULL;
    Scheme_Config *config = NULL;

    MZ_GC_DECL_REG(4);
    MZ_GC_VAR_IN_REG(0, type);
    MZ_GC_VAR_IN_REG(1, op);
    MZ_GC_VAR_IN_REG(2, name);
    MZ_GC_VAR_IN_REG(3, config);
    
    MZ_GC_REG();
    type = (Scheme_Object *)scheme_make_port_type("iGRacket");
    name = (Scheme_Object *)scheme_make_byte_string("iGRacket");
    op = (Scheme_Object *)scheme_make_output_port(type, self, name, NULL,
                                                  igracket_write_bytes,
                                                  igracket_char_ready,
                                                  igracket_close,
                                                  NULL, NULL, NULL, 0);

    config = scheme_current_config();
    scheme_set_param(config, MZCONFIG_OUTPUT_PORT, op);
    MZ_GC_UNREG();
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
    if ([replBuffer.text length] > 0) {
        Scheme_Object *v = NULL;
        Scheme_Env *env = NULL;
        Scheme_Config *config = NULL;

        MZ_GC_DECL_REG(3)
        MZ_GC_VAR_IN_REG(0, v);
        MZ_GC_VAR_IN_REG(1, env);
        MZ_GC_VAR_IN_REG(2, config);
        
        MZ_GC_REG();
        config = scheme_current_config();
        env = scheme_get_env(config);
        v = scheme_intern_symbol("racket");
        scheme_namespace_require(v);
        
        scheme_eval_string_all([replBuffer.text UTF8String], env, 1);
        MZ_GC_UNREG();
    }
    [replBuffer resignFirstResponder];
}

@end
