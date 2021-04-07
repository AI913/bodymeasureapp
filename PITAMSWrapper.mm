//
//  PITAMSWrapper.m
//  PITAMS
//
//  Created by frontarc on 2021/04/06.
//  Copyright © 2021 frontarc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PITAMSWrapper.h"
#import "PITAMS.hpp"
@implementation PITAMSWrapper
- (NSString *) sayHello {
    HelloWorld helloWorld;
    std::string helloWorldMessage = helloWorld.sayHello();
    return [NSString
            stringWithCString:helloWorldMessage.c_str()
            encoding:NSUTF8StringEncoding];
}
@end
