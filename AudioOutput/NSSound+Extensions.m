//
//  NSSound+Extensions.m
//  NSSound+Extensions
//
//  Created by Gabriel Soria Souza on 27/08/21.
//

#import <Cocoa/Cocoa.h>
#import <CoreAudio/CoreAudio.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudioKit/CoreAudioKit.h>
#import "NSSound+Extensions.h"

NS_ASSUME_NONNULL_BEGIN

@implementation NSSound (NSSoundSystemExtension)

+ (AudioDeviceID)obtainDefaultOuputDevice {
    AudioDeviceID returnData = kAudioObjectUnknown;
    unsigned int size = sizeof(returnData);
    AudioObjectPropertyAddress address;
    address.mSelector = kAudioHardwarePropertyDefaultOutputDevice;
    address.mScope = kAudioObjectPropertyScopeGlobal;
    address.mElement = kAudioObjectPropertyElementMain;
    
    AudioObjectID objID = kAudioObjectSystemObject;
    if (!AudioObjectHasProperty(objID, &address)) {
        return returnData;
    }
    
    AudioObjectID propertyID = kAudioObjectSystemObject;
    OSStatus audioError = AudioObjectGetPropertyData(propertyID,
                                                     &address,
                                                     0,
                                                     nil,
                                                     &size,
                                                     &returnData);
    
    if (audioError != noErr) {
        return returnData;
    }
    
    
    return returnData;
}

+ (float) getSystemVolume {
    AudioDeviceID defaultDeviceID = kAudioObjectUnknown;
    unsigned int size = sizeof(defaultDeviceID);
    OSStatus theError;
    float volume = 0;
    AudioObjectPropertyAddress address;
    
    defaultDeviceID = [NSSound obtainDefaultOuputDevice];
    
    if (defaultDeviceID == kAudioObjectUnknown) {
        return 0.0;
    }
    address.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume;
    address.mScope = kAudioDevicePropertyScopeOutput;
    address.mElement = kAudioObjectPropertyElementMain;
    
    if (!AudioObjectHasProperty(defaultDeviceID, &address)) {
        return 0.0;
    }
    
    theError = AudioObjectGetPropertyData(defaultDeviceID,
                                          &address,
                                          0,
                                          nil,
                                          &size,
                                          &volume);
    
    if (theError != noErr) {
        return 0.0;
    }
    
    volume = volume > 1.0 ? 1.0 : (volume < 0.0 ? 0.0 : volume);
    
    return volume;
}

+ (void)setSystemVolume:(float)volume :(BOOL)muteoff {
    float newValue = volume;
    AudioObjectPropertyAddress address;
    AudioDeviceID deviceID;
    OSStatus theError = noErr;
    unsigned int muted;
    Boolean canSetVol = true;
    BOOL muteValue;
    BOOL hasMute = YES;
    Boolean canMute = true;
    
    deviceID = [NSSound obtainDefaultOuputDevice];
    if (deviceID == kAudioObjectUnknown) {
        return;
    }
    
    newValue = volume > 1.0 ? 1.0 : (volume < 0.0 ? 0.0 : volume);
    if (newValue != volume) {
        //
    }
    
    address.mSelector = kAudioDevicePropertyMute;
    address.mScope = kAudioDevicePropertyScopeOutput;
    address.mElement = kAudioObjectPropertyElementMain;
    
    muteValue = (newValue < 0.05);
    if (muteValue) {
        address.mSelector = kAudioDevicePropertyMute;
        hasMute = AudioObjectHasProperty(deviceID, &address);
        
        if (hasMute) {
            theError = AudioObjectIsPropertySettable(deviceID,
                                                     &address,
                                                     &canMute);
            
            if (theError != noErr || !(canMute)) {
                canMute = false;
            }
        } else {
            canMute = false;
        }
    } else {
        address.mSelector = kAudioHardwareServiceDeviceProperty_VirtualMainVolume;
    }
    
    if (!AudioObjectHasProperty(deviceID,
                                &address)) {
        return;
    }
    
    theError = AudioObjectIsPropertySettable(deviceID,
                                             &address,
                                             &canSetVol);
    if (theError != noErr || !canSetVol) {
        return;
    }
    
    if (muteValue && hasMute && canMute) {
        muted = 1;
        theError = AudioObjectSetPropertyData(deviceID,
                                              &address,
                                              0,
                                              nil,
                                              sizeof(muted),
                                              &muted);
        
        if (theError != noErr) {
            return;
        }
    } else {
        theError = AudioObjectSetPropertyData(deviceID,
                                              &address,
                                              0,
                                              nil,
                                              sizeof(newValue),
                                              &newValue);
        if (theError != noErr) {
            //
        }
        
        if (muteoff && hasMute && canMute) {
            address.mSelector = kAudioDevicePropertyMute;
            muted = 0;
            theError = AudioObjectSetPropertyData(deviceID,
                                                  &address,
                                                  0,
                                                  nil,
                                                  sizeof(muted),
                                                  &muted);
        }
    }
}

@end

NS_ASSUME_NONNULL_END

