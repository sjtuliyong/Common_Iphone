//
//  ShoppingKeywordCell.h
//  groupbuy
//
//  Created by LouisLee on 11-8-20.
//  Copyright 2011 ET. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PPTableViewCell.h"

@interface ShoppingKeywordCell : PPTableViewCell {

    UITextField *keywordTextField;
}
@property (nonatomic, retain) IBOutlet UITextField *keywordTextField;

+ (ShoppingKeywordCell*)createCell:(id)delegate;
+ (NSString*)getCellIdentifier;
@end
