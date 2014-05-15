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
- (void)flyPickerDidSelectFly:(NSString *)fly fromPicker:(UIViewController *)picker;
@end
