//
//  AppDelegate.m
//  KEY2MIDI
//
//  Created by Jamie Bullock on 22/03/2014.
//  Copyright (c) 2014 Jamie Bullock. All rights reserved.
//

#import "AppDelegate.h"

#import <CoreMIDI/CoreMIDI.h>

@interface AppDelegate () <NSTextFieldDelegate>
{
    MIDIClientRef   midiClient_;
    MIDIEndpointRef midiOut_;
}

@property (weak) IBOutlet NSLevelIndicator *pageDownLevelIndicator;
@property (weak) IBOutlet NSLevelIndicator *pageUpLevelIndicator;

@property (weak) IBOutlet NSTextField *pageDownTextField;
@property (weak) IBOutlet NSTextField *pageUpTextField;

@property (nonatomic, assign) NSUInteger pageDownCC;
@property (nonatomic, assign) NSUInteger pageUpCC;
@end

@implementation AppDelegate

#pragma mark - UI Handlers

- (IBAction)pageDownTextFieldAction:(id)sender
{
    NSTextField *textField = (NSTextField *)sender;
    self.pageDownCC = [textField.stringValue integerValue];
}

- (IBAction)pageUpTextFieldAction:(id)sender
{
    NSTextField *textField = (NSTextField *)sender;
    self.pageUpCC = [textField.stringValue integerValue];
}

- (void)controlTextDidEndEditing:(NSNotification *)obj
{
    [self.window selectNextKeyView:self];
}

#pragma mark – Key event handling

-(void)handleKeyCode: (NSUInteger)keyCode withKeyDown: (BOOL)keyDown
{
    char packetBuffer[1024];
    MIDIPacketList *packetList = (MIDIPacketList*)packetBuffer;
    MIDIPacket     *packet;
    Byte            CCMessage[] = {0xB0, 0, 0};
    
    switch (keyCode)
    {
        case 115:
            self.pageDownLevelIndicator.integerValue = keyDown ? 1 : 0;
            CCMessage[1] = self.pageDownCC;
            break;
        case 119:
            self.pageUpLevelIndicator.integerValue = keyDown ? 1 : 0;
            CCMessage[1] = self.pageUpCC;
            break;
    }
    
    CCMessage[2] = keyDown ? 127 : 0;
    
    packet = MIDIPacketListInit(packetList);
    packet = MIDIPacketListAdd(packetList, 1024, packet, 0, 3, CCMessage);
    
    MIDIReceived(midiOut_, packetList);
}

-(void)keyDown: (NSNotification *)notification
{
    NSEvent *event = (NSEvent *)notification.object;
    [self handleKeyCode:event.keyCode withKeyDown:YES];
}

-(void)keyUp: (NSNotification *)notification
{
    NSEvent *event = (NSEvent *)notification.object;
    [self handleKeyCode:event.keyCode withKeyDown:NO];
}

#pragma mark - Application life cycle

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    MIDIClientCreate(CFSTR("KEY2MIDI"), NULL, NULL, &midiClient_);
    MIDISourceCreate(midiClient_, CFSTR("KEY2MIDI Source"), &midiOut_);
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyDown:)
                                                 name:@"keyDownEvent"
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyUp:)
                                                 name:@"keyUpEvent"
                                               object:nil];
    
    self.pageDownCC = [self.pageDownTextField.stringValue integerValue];
    self.pageUpCC = [self.pageUpTextField.stringValue integerValue];
}

@end
