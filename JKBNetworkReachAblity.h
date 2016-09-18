//
//  JKBNetworkReachAblity.h
//  Demo0712
//
//  Created by Juster on 16/9/18.
//  Copyright © 2016年 Juster. All rights reserved.
//

#import <Foundation/Foundation.h>
/**
 主线程内发送通知
 通知的name需要通过对象的.notificationName获取
 userInfo内容是
 网络强度：strength：整数 0 1 2 3 给wifi的
 网络类型：0:@"NONE",1:@"2G",2:@"3G",3:@"4G",5:@"WIFI"
 */
@interface JKBNetworkReachAblity : NSObject
//属性
@property (nonatomic,assign,readonly) NSTimeInterval timeInterval;
@property (nonatomic,copy,readonly) NSString * notificationName;





//静态方法返回单利的当前对象
+(instancetype) sharedNetworkReachAblityManager;

//-(instancetype) init;
//-(instancetype) initWithNotificationName:(NSString *)notificationName;
//-(instancetype) initWithTimeInterval:(NSTimeInterval )timeInterval notificaitonName:(NSString *)notificationName;


//不在使用通知的时候一定要将其stop，会停止当前runloop，释放资源
-(void) beginNotificaiton;
-(void) stopNotification;
@end
