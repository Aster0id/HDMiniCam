//
//  TYCameraTimeLineViewSource.h
//  TYCameraBussinessLibrary
//
//  Created by 傅浪 on 2018/9/22.
//

#import <Foundation/Foundation.h>

@protocol TYCameraTimeLineViewSource <NSObject>

- (NSTimeInterval)startTimeIntervalSinceCurrentDay;

- (NSTimeInterval)stopTimeIntervalSinceCurrentDay;

@end
