//
//  AppDelegate.h
//  Contact3
//
//  Created by Admin on 2023/4/14.
//  Copyright © 2023年 TeamTwo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (readonly, strong) NSPersistentContainer *persistentContainer;

- (void)saveContext;


@end

