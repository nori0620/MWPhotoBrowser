//
//  SocialConnect.h
//  TheCleaner
//
//  Created by sakamoto kazuhiro on 2013/06/22.
//  Copyright (c) 2013年 soragoto. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Social/Social.h>

typedef void (^CompletionHandler)();
typedef void (^CancelHandler)();

@interface SNSPost : NSObject

@property (copy, nonatomic) CompletionHandler completionHandler;
@property (copy, nonatomic) CancelHandler cancelHandler;

- (id)initWithSnsType:(NSString *)snsType;
- (void)setMessageBody:(NSString *)messageBody;
- (void)setUrl:(NSString *)url;
- (void)addImageWithFileName:(NSString *)fileName;
- (void)addImageWithUIImage:(UIImage *)image;
- (void)postWithCurrentViewController:(UIViewController *)currentViewController;
- (void)setLinePostTypeImage;
- (void)setLinePostTypeText;
    
@end

