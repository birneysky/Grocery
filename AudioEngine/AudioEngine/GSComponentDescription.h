//
//  GSComponentDescription.hpp
//  AudioEngine
//
//  Created by birney on 2020/2/28.
//  Copyright © 2020 rongcloud. All rights reserved.
//

#ifndef GSComponentDescription_hpp
#define GSComponentDescription_hpp

#import <AudioToolbox/AudioToolbox.h>

struct GSComponentDescription : public AudioComponentDescription  {
    GSComponentDescription() {
        memset (this, 0, sizeof (AudioComponentDescription));
    }
    GSComponentDescription (OSType inType, OSType inSubtype = 0, OSType inManu = 0) {
        componentType = inType;
        componentSubType = inSubtype;
        componentManufacturer = inManu;
        componentFlags = 0;
        componentFlagsMask = 0;
    }
};

#endif 
