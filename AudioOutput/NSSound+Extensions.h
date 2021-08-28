//
//  NSSound+Extensions.h
//  NSSound+Extensions
//
//  Created by Gabriel Soria Souza on 27/08/21.
//


#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>

@interface NSSound (NSSoundSystemExtension)

+ (AudioDeviceID)obtainDefaultOuputDevice;
+ (float) getSystemVolume;
+ (void)setSystemVolume:(float)volume :(BOOL)muteoff;
@end
