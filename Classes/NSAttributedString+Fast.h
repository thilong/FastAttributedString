//
//  NSAttributedString+Fast.h
//  FastAttributedString
//
//  Created by Thilong on 15/4/7.
//  Copyright (c) 2015年 Thilong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSAttributedString (Fast)

+ (instancetype)fast:(NSString *)markedString;

+ (instancetype)fast:(NSString *)markedString defaultFont:(UIFont *)font defaultColor:(UIColor *)color registedFont:(NSDictionary *)registedAttrs;

@end
