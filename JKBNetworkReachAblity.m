//
//  JKBNetworkReachAblity.m
//  Demo0712
//
//  Created by Juster on 16/9/18.
//  Copyright © 2016年 Juster. All rights reserved.
//

#import "JKBNetworkReachAblity.h"
#import <UIKit/UIKit.h>
static const NSString *kNotifyName=@"com.JKB.network.reachabilty";
@interface JKBNetworkReachAblity()
{
    //私有的实例变量
    NSThread *thread;
    NSTimer *timer;
    UIView * dataNetworkItemView;
    int netType;
    int netStrength;
    NSDictionary *netTypeDict;
    
}




@property (nonatomic,assign) NSTimeInterval  timeInterval;
@property (nonatomic,copy) NSString * notificationName;
@property (nonatomic,strong)NSRunLoop *runloop;
@end

@implementation JKBNetworkReachAblity


//单例模式
+(instancetype) sharedNetworkReachAblityManager
{
    static dispatch_once_t oncePredicate;
    static JKBNetworkReachAblity * jkbNetReachAbility;
        dispatch_once(&oncePredicate, ^{
            jkbNetReachAbility=[[self alloc]init];
        });
    
    return jkbNetReachAbility;
}

//开启监听线程
+ (NSThread *)networkReachAbilityThread {
    static NSThread *_networkRequestThread = nil;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _networkRequestThread = [[NSThread alloc] initWithTarget:self selector:@selector(threadEntry:) object:nil];
        [_networkRequestThread start];
    });
    
    return _networkRequestThread;
}

+(void)threadEntry:(id)__unused object
{
    [[NSThread currentThread] setName:@"JKBNetworkReachAbility"];
    NSRunLoop *runloop=[NSRunLoop currentRunLoop];
    [runloop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
    //[runloop runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];//能在取消的时候杀死线程
    [runloop run];
    
}

-(instancetype) init
{
    return [self initWithNotificationName:[kNotifyName copy]];
    
}
-(instancetype) initWithNotificationName:(NSString *)notificationName
{
    //每10秒检测一次
    return [self initWithTimeInterval:5.0 notificaitonName:notificationName];
}
-(instancetype) initWithTimeInterval:(NSTimeInterval )timeInterval notificaitonName:(NSString *)notificationName
{
    
    if(self=[super init])
    {
        
        _timeInterval=timeInterval;
        _notificationName=notificationName;
        dataNetworkItemView=[self dataNetworkItemView];
        netTypeDict=@{@0:@"NONE",@1:@"2G",@2:@"3G",@3:@"4G",@5:@"WIFI"};
        netStrength=-1;
        netType=-1;
    }
    return self;
}
-(void)beginNotificaiton
{
    thread =[JKBNetworkReachAblity networkReachAbilityThread];//线程生成之后就启动了
    [self performSelector:@selector(beginTimer) onThread:thread withObject:nil waitUntilDone:NO];
}
-(void)beginTimer
{
    
    timer=[NSTimer scheduledTimerWithTimeInterval:self.timeInterval target:self selector:@selector(postNotification:) userInfo:nil repeats:YES];
   
}
-(void)postNotification:(id)userInfo
{
    
    //发送给主线程检测网络是否发生变化==>网络强度和网络网络类型
    int signalStrength = [[dataNetworkItemView valueForKey:@"_wifiStrengthBars"] intValue];
    
    int net= [[dataNetworkItemView valueForKeyPath:@"dataNetworkType"] intValue];
    if(signalStrength==netStrength && net==netType)
        return;
    else
    {
        netStrength=signalStrength;
        netType=net;
    }
    
    NSNumber *strength=[NSNumber numberWithInteger:signalStrength];
    NSNumber *networkType=[NSNumber numberWithInteger:net];
    NSDictionary *dict=@{@"strength":strength,@"netType":netTypeDict[networkType]};
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [[NSNotificationCenter defaultCenter]postNotificationName:self.notificationName object:nil userInfo:dict];
    });
}


-(id)dataNetworkItemView
{
    UIApplication * application=[UIApplication sharedApplication];
    NSArray *subviews=[[[application valueForKey:@"statusBar"] valueForKey:@"foregroundView"] subviews];
    for (id subview in subviews) {
        if([subview isKindOfClass:[NSClassFromString(@"UIStatusBarDataNetworkItemView") class]]) {
            dataNetworkItemView = subview;
            break;
        }
    }
    return dataNetworkItemView;
}

-(void)stopNotification
{
    [timer invalidate];
    [thread cancel];
}
@end
