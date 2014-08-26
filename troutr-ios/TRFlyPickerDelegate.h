//
//  TRFlyPickerDelegate.h
//  Pods
//
//  Created by Horace Williams on 5/14/14.
//
//

#import <Foundation/Foundation.h>

@protocol TRFlyPickerDelegate <NSObject>
@required
- (void)flyPickerDidSelectItem:(NSString *)item fromPicker:(UIViewController *)picker;
@end
