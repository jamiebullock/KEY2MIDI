//
//  MainView.m
//  KEY2MIDI
//
//  Created by Jamie Bullock on 22/03/2014.
//  Copyright (c) 2014 Jamie Bullock. All rights reserved.
//

#import "MainView.h"

@implementation MainView

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

-(BOOL)acceptsFirstResponder
{
    return YES;
}

-(void)keyDown:(NSEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"keyDownEvent"
                                                        object:event
                                                      userInfo:@{@"sender":self}];
}

-(void)keyUp:(NSEvent *)event
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"keyUpEvent"
                                                        object:event
                                                      userInfo:@{@"sender":self}];
}


@end
