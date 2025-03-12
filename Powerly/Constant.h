//
//  Constant.h
//  kazumi
//
//  Created by Yashvir on 14/11/15.
//  Copyright © 2015 Nishkrant Media. All rights reserved.
//

#ifndef Constant_h
#define Constant_h

#ifdef DEBUG
 #   define NSLog(...) NSLog(__VA_ARGS__)
 #else
 #   define NSLog(...) (void)0
 #endif

#define kUserAddressKey @"address"
#define kUserAddressRegKey @"users_address"
#define kUserLastSavedKey  @"last_saved_screen"
#define kUserContactNumberKey @"contact_number"
#define kLanguageType  @"LanguageType"
#define isLanguageArabic ([[[NSUserDefaults standardUserDefaults] valueForKey:@"LanguageValue"] isEqualToString:@"2"])

#define USERDEFAULTS ([NSUserDefaults standardUserDefaults])

#endif /* Constant_h */
