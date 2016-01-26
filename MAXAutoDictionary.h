//
//  MAXAutoDictionary.h
//  MAXAutoDictionary
//
//  Created by golven on 15/11/5.
//  Copyright © 2015年 Max. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIKit/UIKit.h"

@interface MAXAutoDictionary : NSObject

//可以是其他类型，并不一定是NSDate
@property (nonatomic, strong) NSDate *date;

@property (nonatomic, strong) NSString *string;

@property (nonatomic, strong) NSNumber *number;

@property (nonatomic, strong) UIView   *view;

+ setClassString:(NSString *)string;

@end
