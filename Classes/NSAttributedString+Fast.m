//
//  NSAttributedString+Fast.m
//  FastAttributedString
//
//  Created by Thilong on 15/4/7.
//  Copyright (c) 2015年 Thilong. All rights reserved.
//

#import "NSAttributedString+Fast.h"
#import <UIKit/UIKit.h>

#if __has_feature(objc_arc)
#   define __RELEASE(_obj)
#   define __AUTORELEASE(_obj) (_obj)
#else
#   define __RELEASE(_obj) ([_obj release])
#   define __AUTORELEASE(_obj) ([_obj autorelease])
#endif

bool OnlyNumber(NSString *str){
    const char *cStr = str.UTF8String;
    for(int i=0;i< strlen(cStr);++i){
        char c = cStr[i];
        if(c < '0' || c > '9')
            return false;
    }
    return true;
}

CGFloat colorComponentFromString(NSString *col){
    float result=0.0f;
    const char *cStr = col.UTF8String;
    size_t total_len = strlen(cStr);
    for(int i=0;i< total_len;++i){
        char c = cStr[i];
        int intVal = 0;
        if(c <='9' && c >= '0')
            intVal = (c - '0');
        else if(c >= 'A' && c < 'F')
            intVal = (c - 'A') + 10;
        else if(c >= 'a' && c < 'f')
            intVal = (c - 'a') + 10;
        
        result += pow(16, (total_len - i - 1)) * intVal;
    }
    return result / 255.0f;
}


UIColor * colorWithHexString(NSString * hexString){
    NSString *colorString = hexString;
    CGFloat alpha, red, blue, green;
    switch ([colorString length]) {
        case 3: // #RGB
            alpha = 1.0f;
            red   = colorComponentFromString([hexString substringWithRange:NSMakeRange(0,1)]);
            green = colorComponentFromString([hexString substringWithRange:NSMakeRange(1,1)]);
            blue  = colorComponentFromString([hexString substringWithRange:NSMakeRange(2,1)]);
            break;
        case 4: // #ARGB
            alpha = colorComponentFromString([hexString substringWithRange:NSMakeRange(0,1)]);
            red   = colorComponentFromString([hexString substringWithRange:NSMakeRange(1,1)]);
            green = colorComponentFromString([hexString substringWithRange:NSMakeRange(2,1)]);
            blue  = colorComponentFromString([hexString substringWithRange:NSMakeRange(3,1)]);
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = colorComponentFromString([hexString substringWithRange:NSMakeRange(0,2)]);
            green = colorComponentFromString([hexString substringWithRange:NSMakeRange(2,2)]);
            blue  = colorComponentFromString([hexString substringWithRange:NSMakeRange(4,2)]);
            break;
        case 8: // #AARRGGBB
            alpha = colorComponentFromString([hexString substringWithRange:NSMakeRange(0,2)]);
            red   = colorComponentFromString([hexString substringWithRange:NSMakeRange(2,2)]);
            green = colorComponentFromString([hexString substringWithRange:NSMakeRange(4,2)]);
            blue  = colorComponentFromString([hexString substringWithRange:NSMakeRange(6,2)]);
            break;
        default:
            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

@implementation NSAttributedString (Fast)

+ (instancetype)fast:(NSString *)markedString{
    return  [NSAttributedString fast:markedString defaultFont:[UIFont systemFontOfSize:14] defaultColor:[UIColor blackColor] registedFont:nil];
}

+ (instancetype)fast:(NSString *)markedString defaultFont:(UIFont *)font defaultColor:(UIColor *)color registedFont:(NSDictionary *)registedFonts{
    __block NSMutableAttributedString *result = [NSMutableAttributedString new];
    
    NSArray *attrStrGroup = [markedString componentsSeparatedByString:@"[*"];
    [attrStrGroup enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray *attrAndStr = [(NSString *)obj componentsSeparatedByString:@"*]"];
        if ([attrAndStr count] == 1)
        {
            NSAttributedString *str = [[NSAttributedString alloc] initWithString:attrAndStr[0]];
            [result appendAttributedString:str];
            __RELEASE(str);
            return;
        }
        
        NSString *attrStr = ((NSString *)attrAndStr[0]) ;
        NSString *strStr = attrAndStr[1];
        
        NSArray *attrs = [attrStr componentsSeparatedByString:@" "];
        
        __block NSMutableDictionary *attrDic = [NSMutableDictionary new];
        attrDic[NSFontAttributeName] = font;
        attrDic[NSForegroundColorAttributeName] = color;
        [attrs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *attrKey = obj;
            if([attrKey length]==0)
                return;
            if([attrKey hasPrefix:@"#"]){ //Color
                UIColor *speColor = colorWithHexString([attrKey substringWithRange:NSMakeRange(1, attrKey.length -1)]);
                attrDic[NSForegroundColorAttributeName] = speColor;
            }
            else if(OnlyNumber(attrKey)){ //font size
                CGFloat fontSize = (CGFloat)atoi(attrKey.UTF8String);
                attrDic[NSFontAttributeName] = [UIFont fontWithName:font.familyName size:fontSize];
            }
            else{ // font name
                if(registedFonts && registedFonts[attrKey])
                    attrDic[NSFontAttributeName] = registedFonts[attrKey];
            }
        }];
        
        NSAttributedString *str = [[NSAttributedString alloc] initWithString:strStr attributes:attrDic];
        [result appendAttributedString:str];
        __RELEASE(str);
        __RELEASE(attrDic);
        
    }];
    
    return __AUTORELEASE(result);
}

@end
