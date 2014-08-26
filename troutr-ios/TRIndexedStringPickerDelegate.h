//
//  TRIndexedStringPickerDelegate.h
//  troutr-ios
//
//  Created by Horace Williams on 8/26/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import <Foundation/Foundation.h>
@class TRIndexedStringPickerViewController;

@protocol TRIndexedStringPickerDelegate <NSObject>
- (void)pickerDidSelectItem:(NSString *)item fromPicker:(TRIndexedStringPickerViewController *)picker;
@end
