//
//  ASAppDelegate.h
//  anusmriti
//
//  Created by Rammohan Vangapalli on 1/9/17.
//  Copyright © 2017 ram. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface ASAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

