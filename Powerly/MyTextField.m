//
//  MyTextField.m
//  PowerShare
//
//  Created by Jaydeep on 12/12/19.
//  Copyright © 2019 JASYC. All rights reserved.
//






#import "MyTextField.h"


@implementation MyTextField

- (void)deleteBackward {
    [super deleteBackward];

   [_myDelegate textFieldDidDelete:self];
}
@end
