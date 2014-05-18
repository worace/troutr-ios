//
//  TRCatchTableViewCell.h
//  troutr-ios
//
//  Created by Horace Williams on 5/18/14.
//
//

#import <UIKit/UIKit.h>

@interface TRCatchTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *tumbnailView;
@property (weak, nonatomic) IBOutlet UILabel *speciesLabel;
@property (weak, nonatomic) IBOutlet UILabel *flyLabel;
@end
