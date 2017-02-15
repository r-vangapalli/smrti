//
//  ASClipListViewController.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/12/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ASItem;

@interface ASClipListViewController : UIViewController

- (void)refresh;
- (void)selectNextClip;
- (void)clearSelection;
@end
