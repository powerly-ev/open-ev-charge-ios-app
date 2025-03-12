//
//  MyTextField.h
//  PowerShare
//
//  Created by Jaydeep on 12/12/19.
//  Copyright © 2019 JASYC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyTextFieldDelegate <NSObject>
@optional
- (void)textFieldDidDelete:(UITextField*_Nullable)txt;
@end


NS_ASSUME_NONNULL_BEGIN

@interface MyTextField : UITextField
@property (nonatomic, assign) id<MyTextFieldDelegate> myDelegate;
@end

NS_ASSUME_NONNULL_END
