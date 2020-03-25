//
//  NSString+Utility.m
//  KHJCamera
//
//  Created by kevin on 2019/3/11.
//  Copyright © 2019 FKHJ. All rights reserved.
//

#import "NSString+Utility.h"

@implementation NSString (Utility)

- (NSUInteger)charactorNumber
{
    NSStringEncoding encoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    return [self charactorNumberWithEncoding:encoding];
}

- (NSUInteger)charactorNumberWithEncoding:(NSStringEncoding)encoding
{
    NSUInteger strLength = 0;
    char *p = (char *)[self cStringUsingEncoding:encoding];
    
    NSUInteger lengthOfBytes = [self lengthOfBytesUsingEncoding:encoding];
    for (int i = 0; i < lengthOfBytes; i++) {
        if (*p) {
            p++;
            strLength++;
        }
        else {
            p++;
        }
    }
    return strLength;
}

@end
