//
//  MCReturnRate.h
//  MingCe
//
//  Created by haoliqiang on 16/12/7.
//  Copyright © 2016年 private team. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MCReturnRate : NSObject
@property (nonatomic, assign) int date;
@property (nonatomic, assign) double returnRate; //等额本息
@property (nonatomic, assign) double refReturnRate;//等额本金

@property (nonatomic, copy) NSString *fundDate;







@end
