//
//  TRCatchImagePickerViewController.m
//  troutr-ios
//
//  Created by Horace Williams on 5/14/14.
//  Copyright (c) 2014 WoracesWorkshop. All rights reserved.
//

#import "TRCatchImagePickerViewController.h"
#import "TRCatchDataEntryViewController.h"

@interface TRCatchImagePickerViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@end

@implementation TRCatchImagePickerViewController

- (IBAction)takePhoto:(UIButton *)sender {
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = YES;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:nil];
    } else {
        [self displayCameraNotAvailableAlert];
    }
}

- (IBAction)chooseExisting:(UIButton *)sender {
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate = self;
    picker.allowsEditing = YES;
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)displayCameraNotAvailableAlert {
    [[[UIAlertView alloc] initWithTitle:@"error"
                                message:@"no camera available"
                               delegate:nil
                      cancelButtonTitle:@"ok"
                      otherButtonTitles:nil] show];
}

- (IBAction)skipPhoto:(UIButton *)sender {
    [self advanceToCatchInfo];
}

- (void)advanceToCatchInfo {
    [self.catchInProgress setImage:self.selectedImage];
    TRCatchDataEntryViewController *catchInfoStep = [[TRCatchDataEntryViewController alloc] init];
    catchInfoStep.catchInProgress = self.catchInProgress;
    [self.navigationController pushViewController:catchInfoStep animated:YES];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info {
    self.selectedImage = info[UIImagePickerControllerEditedImage];
    self.imageView.image = self.selectedImage;
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self advanceToCatchInfo];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:YES completion:nil];
}


@end
