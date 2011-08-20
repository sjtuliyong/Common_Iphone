//
//  SliderCell.h
//  groupbuy
//
//  Created by LouisLee on 11-8-20.
//  Copyright 2011 ET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@interface SliderCell : PPTableViewCell {

}

+ (SliderCell*)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
+ (CGFloat)getCellHeight;
@end
