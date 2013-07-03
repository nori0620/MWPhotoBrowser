//
//  SocialConnect.m
//  TheCleaner
//
//  Created by sakamoto kazuhiro on 2013/06/22.
//  Copyright (c) 2013年 soragoto. All rights reserved.
//

#import "SNSPost.h"

@implementation SNSPost{
    NSString *_snsType;
    NSString *_messageBody;
    NSString *_url;
    NSString *_imageFileName;
    UIImage  *_image;
    NSString *_linePostType;
    UIViewController *_currentViewController;
}

- (NSArray *)_AVAILABLE_SNS{
    return @[@"twitter",
             @"facebook",
             @"line"
    ];
}

- (id)initWithSnsType:(NSString *)snsType
{
    self = [super init];
    if (self) {
        NSAssert([[self _AVAILABLE_SNS] containsObject:snsType],
                @"sns type [%@] is not supported", snsType);
        _snsType      = snsType;
        _linePostType = @"text";
        [self _initCallbackHandler];
    }
    return self;
}

-(void)_initCallbackHandler{
    [self setCancelHandler:^{
    }];
    [self setCompletionHandler:^{
    }];
}

-(void)setLinePostTypeImage{
    _linePostType = @"image";
}

-(void)setLinePostTypeText{
    _linePostType = @"text";
}

-(void)setMessageBody:(NSString *)messageBody{
    _messageBody = messageBody;
}

-(void)setUrl:(NSString *)url{
    _url = url;
}

-(void)addImageWithUIImage:(UIImage *)image{
    _image = image;
}

-(void)addImageWithFileName:(NSString *)fileName{
    _imageFileName = fileName;
}

- (void)postWithCurrentViewController:(UIViewController *)currentViewController{
    _currentViewController = currentViewController;
    if([_snsType isEqualToString:@"facebook"] ||
       [_snsType isEqualToString:@"twitter"]){
        [self _postBySocialFrameWork];
    }
    if([_snsType isEqualToString:@"line"]){
        [self _postToLine];
    }
}

- (void)_postToLine{
    if ([_linePostType isEqualToString:@"text"]) {
        [self _postTextToLine];
    }
    if ([_linePostType isEqualToString:@"image"]) {
        [self _postImageToLine];
    }
}

- (void)_postImageToLine {
    
    UIImage *sendImage;
    
    if(_imageFileName){
        sendImage = [UIImage imageNamed:_imageFileName];
    }
    
    if(_image){
        sendImage = _image;
    }
    
    UIPasteboard * board = [UIPasteboard pasteboardWithUniqueName];
    [board setData:UIImagePNGRepresentation(sendImage) forPasteboardType:@"public.png"];
    NSString *urlStr = [NSString stringWithFormat:@"line://msg/image/%@", board.name];
    NSURL* url = [NSURL URLWithString:urlStr];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"LINE not installed", nil)
                                                         message:NSLocalizedString(@"LINE is not installed in your device.", nil)
                                                        delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss", nil) otherButtonTitles:nil] autorelease];
		[alert show];
    }
    
    self.completionHandler();
}

- (void)_postTextToLine {
    NSString *plainString = [NSString stringWithFormat:@"%@ %@", _messageBody, _url];
    NSString *contentKey = (__bridge NSString *)
    CFURLCreateStringByAddingPercentEscapes(NULL,
                                            (CFStringRef)plainString,
                                            NULL,
                                            (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                            kCFStringEncodingUTF8 );
    
    NSString *contentType = @"text";
    NSString *urlString = [NSString
                           stringWithFormat: @"line://msg/%@/%@",
                           contentType, contentKey];
    
    self.completionHandler();
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlString]];
}

-(void)_postBySocialFrameWork{
    
    SLComposeViewController *slComposeViewController = [SLComposeViewController composeViewControllerForServiceType:[self _slServiveType]];
    
    [slComposeViewController setInitialText:_messageBody];
    
    if(_imageFileName){
        [slComposeViewController addImage:[UIImage imageNamed:_imageFileName]];
    }
    
    if(_image){
        [slComposeViewController addImage:_image];
    }
    
    if(_url){
        [slComposeViewController addURL:[NSURL URLWithString:_url]];
    }
    
    __block SLComposeViewController *slViewControllerInBlock = slComposeViewController;
    [slComposeViewController setCompletionHandler:^(SLComposeViewControllerResult result) {
        switch (result) {
            case SLComposeViewControllerResultDone:
                self.completionHandler();
                [slViewControllerInBlock dismissViewControllerAnimated:YES completion:nil];
                break;
            case SLComposeViewControllerResultCancelled:
                self.cancelHandler();
                [slViewControllerInBlock dismissViewControllerAnimated:YES completion:nil];
                break;
        }
    }];
    
    [_currentViewController presentViewController:slComposeViewController animated:YES completion:nil];
}

-(NSString *)_slServiveType{
    if([_snsType isEqualToString:@"facebook"]){
        return SLServiceTypeFacebook;
    }
    if([_snsType isEqualToString:@"twitter"]){
        return SLServiceTypeTwitter;
    }
    return nil;
}

@end
