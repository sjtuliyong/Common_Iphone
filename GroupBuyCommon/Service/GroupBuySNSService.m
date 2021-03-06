//
//  GroupBuySNSService.m
//  Dipan
//
//  Created by qqn_pipi on 11-6-6.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "GroupBuySNSService.h"
#import "PPViewController.h"
#import "GroupBuyUserService.h"
#import "VariableConstants.h"
#import "NetworkUtil.h"
#import "StringUtil.h"
#import "UINavigationBarExt.h"


#define SINA_APP_KEY                    @"2457135690"
#define SINA_APP_SECRET                 @"9886c6c3a5683950bad471b44f47a312"

#define QQ_APP_KEY                      @"801063695"
#define QQ_APP_SECRET                   @"e65f5ba72a75725032e5ee26c71d71d3"

typedef void (^AuthorizationSuccessHandler)(NSDictionary*, PPViewController*);

@implementation GroupBuySNSService

@synthesize sinaRequest;
@synthesize qqRequest;
@synthesize sinaAppkey;
@synthesize sinaAppSecret;
@synthesize qqAppKey;
@synthesize qqAppSecret;
@synthesize renrenAppKey;
@synthesize renrenAppSecret;

- (void)initAppKeyValue{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    self.sinaAppkey = SINA_APP_KEY;//[userDefaults stringForKey:USER_DEFAULT_SINA_KEY];
    self.sinaAppSecret = SINA_APP_SECRET;//[userDefaults stringForKey:USER_DEFAULT_SINA_SECRET];
    self.qqAppKey = QQ_APP_KEY;//[userDefaults stringForKey:USER_DEFAULT_QQ_KEY];
    self.qqAppSecret = QQ_APP_SECRET;//[userDefaults stringForKey:USER_DEFAULT_QQ_SECRET];
    self.renrenAppKey = [userDefaults stringForKey:USER_DEFAULT_RENREN_KEY];
    self.renrenAppSecret = [userDefaults stringForKey:USER_DEFAULT_RENREN_SECRET];
}

- (id)init
{
    self = [super init];
    
    workingQueue = dispatch_queue_create("sns service queue", NULL);
    
    [self initAppKeyValue];
    
    self.sinaRequest = [[SINAWeiboRequest alloc] initWithAppKey:self.sinaAppkey
                                                      appSecret:self.sinaAppSecret
                                                    callbackURL:nil
                                                     oauthToken:nil
                                               oauthTokenSecret:nil];
    
    self.qqRequest = [[QQWeiboRequest alloc] initWithAppKey:self.qqAppKey
                                                  appSecret:self.qqAppSecret
                                                callbackURL:@"null"
                                                 oauthToken:nil
                                           oauthTokenSecret:nil];
    
    return self;
}

- (void)dealloc
{
    
    dispatch_release(workingQueue);
    workingQueue = NULL;
    
    [sinaRequest release];
    [qqRequest release];
    
    [sinaAppkey release];
    [sinaAppSecret release];
    [qqAppKey release];
    [qqAppSecret release];
    [renrenAppKey release];
    [renrenAppSecret release];
    
    [sinaRequest release];
    [qqRequest release];
    [super dealloc];
    
}

#pragma mark - Cache Handling

- (BOOL)hasQQCacheData
{
    return [qqRequest hasUserInfoCache];
}

- (BOOL)hasSinaCacheData
{
    return [sinaRequest hasUserInfoCache];    
}


- (void)setSinaAppKey: (NSString *)key Secret:(NSString *)secret{
    [self setSinaAppkey:key];
    [self setSinaAppSecret:secret];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:key forKey:USER_DEFAULT_SINA_KEY];
    [userDefaults setObject:secret forKey:USER_DEFAULT_SINA_SECRET];
}

- (void)setQQAppKey: (NSString *)key Secret:(NSString *)secret{
    [self setQqAppKey:key];
    [self setQqAppSecret:secret];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:key forKey:USER_DEFAULT_QQ_KEY];
    [userDefaults setObject:secret forKey:USER_DEFAULT_QQ_SECRET];
}

- (void)setRenrenAppKey: (NSString *)key Secret:(NSString *)secret{
    [self setRenrenAppKey:key];
    [self setRenrenAppSecret:secret];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:key forKey:USER_DEFAULT_RENREN_KEY];
    [userDefaults setObject:secret forKey:USER_DEFAULT_RENREN_SECRET];
}

//#pragma mark - Handle Authroization Response
//
//- (void)handleParseAuthorizationResponseURL:(CommonSNSRequest*)snsRequest 
//                                      query:(NSString*)query 
//                             viewController:(PPViewController*)viewController 
//                             successHandler:(AuthorizationSuccessHandler)successHandler
//{
//    [viewController showActivityWithText:NSLS(@"kCheckAuthorizationResponse")];
//    dispatch_async(workingQueue, ^{                
//        BOOL finalResult = YES;
//        // parse authorization response
//        int result = [self parseAuthorizationResponseURL:query snsRequest:snsRequest];
//        if (result != 0)
//            finalResult = NO;
//        
//        // get user info
//        NSDictionary* userInfo = [self getUserInfo:snsRequest];
//        if (userInfo != nil){            
//            
//            // success
//            finalResult = YES;
//            dispatch_async(dispatch_get_main_queue(), ^{
//                successHandler(userInfo, viewController);
//            });            
//            
//        }
//        else{
//            finalResult = NO;
//        }                
//        
//        if (finalResult == NO){
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [viewController hideActivity]; 
//                [UIUtils alert:NSLS(@"kAuthorizationFailure")];
//            });            
//        }                
//    });
//}
//
//- (void)sinaParseAuthorizationResponseURL:(NSString *)query viewController:(PPViewController*)viewController successHandler:(AuthorizationSuccessHandler)successHandler
//{
//    [self handleParseAuthorizationResponseURL:sinaRequest query:query viewController:viewController successHandler:successHandler];    
//}
//
//- (void)qqParseAuthorizationResponseURL:(NSString *)query viewController:(PPViewController*)viewController successHandler:(AuthorizationSuccessHandler)successHandler
//{
//    [self handleParseAuthorizationResponseURL:qqRequest query:query viewController:viewController successHandler:successHandler];    
//}

#pragma mark - Initate Login Request

- (void)snsInitiateLogin:(PPViewController*)viewController snsRequest:(CommonSNSRequest*)snsRequest
{
    displayViewController = viewController; // save the view controller to parse reponse URL
    
    [viewController showActivityWithText:NSLS(@"kInitiateAuthorization")];
    dispatch_async(workingQueue, ^{        
        BOOL result = [self loginForAuthorization:snsRequest viewController:viewController];
        dispatch_async(dispatch_get_main_queue(), ^{
            [viewController hideActivity];
            if (result == NO){
                [UIUtils alert:NSLS(@"kFailInitAuthorization")];                
            }
        });        
    });        
}

- (void)sinaInitiateLogin:(PPViewController*)viewController //loginSuccessHandler:(LoginSuccessHandler)handler
{
//    loginSuccessHandler = handler;
    [self snsInitiateLogin:viewController snsRequest:sinaRequest];
}

- (void)qqInitiateLogin:(PPViewController*)viewController //loginSuccessHandler:(LoginSuccessHandler)handler

{
//    loginSuccessHandler = handler;
    [self snsInitiateLogin:viewController snsRequest:qqRequest];
}



//- (void)sinaParseAuthorizationResponseURL:(NSString *)query
//{
//    [self sinaParseAuthorizationResponseURL:query viewController:displayViewController successHandler:groupBuySnsAuthorizeSuccess];
//}
//
//- (void)qqParseAuthorizationResponseURL:(NSString *)query
//{
//    [self qqParseAuthorizationResponseURL:query viewController:displayViewController successHandler:groupBuySnsAuthorizeSuccess];    
//}

- (void)syncWeiboToAllSNS:(NSString*)text viewController:(PPViewController*)viewController
{
    if ([text length] == 0)
        return;
    
    UserService* userService = GlobalGetUserService();
    if ([userService hasUserBindQQ]){
        dispatch_async(workingQueue, ^{
            [self sendText:text snsRequest:qqRequest]; 
        });
    }
    
    if ([userService hasUserBindSina]){
        dispatch_async(workingQueue, ^{
            [self sendText:text snsRequest:sinaRequest]; 
        });
    }
    
}

// block function for authroization successful
AuthorizationSuccessHandler groupBuySnsAuthorizeSuccess = ^(NSDictionary* userInfo, PPViewController* viewController){
    
    
    
};

// parse PIN from UIWebView pages
- (void)finishParsePin:(int)pinResult pin:(NSString*)pin snsRequest:(CommonSNSRequest *)snsRequest
{
    [displayViewController showActivityWithText:NSLS(@"请求授权中...")];
    dispatch_async(workingQueue, ^{                
        BOOL finalResult = YES;
        // parse authorization response
        BOOL result = [self parsePin:pinResult pin:pin snsRequest:snsRequest];
        if (result == NO)
            finalResult = NO;
        
        // get user info
        NSDictionary* userInfo = [self getUserInfo:snsRequest];
        if (userInfo != nil){            
            
            // success
            finalResult = YES;
            dispatch_async(dispatch_get_main_queue(), ^{
                [displayViewController.navigationController popViewControllerAnimated:NO];
                
                UserService* userService = GlobalGetUserService();
                [userService groupBuyRegisterUserWithSNSUserInfo:userInfo 
                                                  viewController:displayViewController];                       
            });            
            
        }
        else{
            finalResult = NO;
        }                
        
        if (finalResult == NO){
            dispatch_async(dispatch_get_main_queue(), ^{
                [displayViewController hideActivity]; 
                [UIUtils alert:NSLS(@"不好意思，授权失败了")];
            });            
        }                
    });    
}


@end
