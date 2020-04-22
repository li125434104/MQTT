//
//  MQTTManager.m
//  HaiTing
//
//  Created by taishu on 2020/3/16.
//  Copyright © 2020 taishu. All rights reserved.
//

#import "MQTTManager.h"
#import "MQTTClient.h"

@interface MQTTManager ()<MQTTSessionDelegate>

@property (strong, nonatomic) NSDictionary *dicMqttList;
@property (nonatomic, strong) MQTTSession *session;
@property (nonatomic, strong) NSString *chatRommId;

@end

@implementation MQTTManager

+ (MQTTManager *)sharedInstance {
    static MQTTManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

#pragma mark - 初始化MQTT
- (void)startMqtt {
    NSURL *urlBundle = [[NSBundle mainBundle] bundleURL];
    NSURL *urlList = [urlBundle URLByAppendingPathComponent:@"MQTT.plist"];
    self.dicMqttList = [NSDictionary dictionaryWithContentsOfURL:urlList];
    
    MQTTCFSocketTransport *transport = [[MQTTCFSocketTransport alloc] init];
    transport.host = self.dicMqttList[@"host"];
    transport.port = [self.dicMqttList[@"port"] intValue];
    
    self.session = [[MQTTSession alloc] init];
    self.session.transport = transport;
    self.session.delegate = self;
    [self.session setUserName:@"test01"];
    [self.session setPassword:@"8d969eef6ecad3c29a3a629280e686cf0c3f5d5a86aff3ca12020c923adc6c92"];
//    [self.session setClientId:@"GID_haiting@@@test"];
    [self.session connectWithConnectHandler:^(NSError *error) {
        
    }];
    
    [self.session addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew context:nil];
}

- (MQTTSessionStatus)getMqttStatus {
    return self.session.status;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    switch (self.session.status) {
        case MQTTSessionStatusClosed:
            NSLog(@"已经关闭");
            _getMqttPingStatusB(@"已经关闭");
            break;
        case MQTTSessionStatusDisconnecting:
            NSLog(@"关闭中");
            _getMqttPingStatusB(@"关闭中");
            break;
        case MQTTSessionStatusConnected:
            
            NSLog(@"已经连接");
            _getMqttPingStatusB(@"已经连接");
            break;
        case MQTTSessionStatusConnecting:
            NSLog(@"连接中");
//            _getMqttPingStatusB(@"连接中");
            break;
        case MQTTSessionStatusError:
            NSLog(@"状态error");
            _getMqttPingStatusB(@"状态error");
            break;
        case MQTTSessionStatusCreated:
            NSLog(@"开始链接");
            _getMqttPingStatusB(@"开始链接");
            
        default:
            break;
    }
}

#pragma mark - 断开MQTT
- (void)disMQTTConnect {
    [self.session removeObserver:self forKeyPath:@"status"];
    [self.session disconnect];
    self.session = nil;
}

#pragma mark - 断开MQTT从聊天中
- (void)disMQTTConnectWithStrTopic:(NSString *)strTopic {
//    [_manager sendData:[@"leaves chat" dataUsingEncoding:NSUTF8StringEncoding]
//                 topic:strTopic
//                   qos:MQTTQosLevelExactlyOnce
//                retain:FALSE];
//    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];
//    [_manager disconnectWithDisconnectHandler:^(NSError *error) {
//
//    }];
}

- (void)addTopicWithName:(NSString *)topic {
    [self.session subscribeToTopic:topic atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"%@主题订阅失败 %@", topic, error.localizedDescription);
        } else {
            NSLog(@"%@主题订阅成功 Granted Qos: %@", topic, gQoss);
        }
    }];
}

#pragma mark - 订阅主题
- (void)subscribeChatRomm:(NSString *)chatRoomId resultBlcok:(void(^)(BOOL success))result {
    [self.session subscribeToTopic:[NSString stringWithFormat:@"sys_chat/%@", chatRoomId] atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"%@直播间进入失败 %@", chatRoomId, error.localizedDescription);
            result(NO);
        } else {
            NSLog(@"%@直播间进入成功 Granted Qos: %@", chatRoomId, gQoss);
            self.chatRommId = chatRoomId;
            result(YES);
        }
    }];
}

#pragma mark -- 取消订阅
- (void)unsubscribeChatRoom:(NSString *)chatRoomId resultBlcok:(void(^)(BOOL success))result {
    [self.session unsubscribeTopic:[NSString stringWithFormat:@"sys_chat/%@", chatRoomId] unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@退出直播间失败 %@", chatRoomId, error.localizedDescription);
            result(NO);
        } else {
            NSLog(@"%@退出直播间成功", chatRoomId);
            self.chatRommId = chatRoomId;
            result(YES);
        }
    }];
}

- (void)subscribeMineResultBlock:(void(^)(BOOL success))result {
    [self.session subscribeToTopic:[NSString stringWithFormat:@"sys_chat/%@", LoginUserId] atLevel:MQTTQosLevelExactlyOnce subscribeHandler:^(NSError *error, NSArray<NSNumber *> *gQoss) {
        if (error) {
            NSLog(@"%@用户订阅自己失败 %@", LoginUserId, error.localizedDescription);
            result(NO);
        } else {
            NSLog(@"%@用户订阅自己成功 Granted Qos: %@", LoginUserId, gQoss);
            result(YES);
        }
    }];
}

- (void)unsubscribeMineResultBlock:(void(BOOL success))result {
    [self.session unsubscribeTopic:[NSString stringWithFormat:@"sys_chat/%@", LoginUserId] unsubscribeHandler:^(NSError *error) {
        if (error) {
            NSLog(@"%@用户取消订阅自己失败 %@", LoginUserId, error.localizedDescription);
            result(NO);
        } else {
            NSLog(@"%@用户取消订阅自己成功", LoginUserId);
            result(YES);
        }
    }];
}

#pragma mark - 发消息
- (void)sendTextMessage:(IMTextModel *)model inChatRoom:(NSString *)chatRoomId {
    NSString *topicChatRoomId = [NSString stringWithFormat:@"sys_chat/%@", chatRoomId];
    if ([chatRoomId isEqualToString:self.chatRommId]) {
        NSData *data = [model mj_JSONData];
        [self.session publishData:data onTopic:topicChatRoomId retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
            if (error) {
                NSLog(@"消息发送失败");
            } else {
                NSLog(@"消息发送成功");
            }
        }];
    }
}

- (void)sendLianMaiMessage:(IMTextModel *)model toAnchor:(NSString *)anchorId {
    NSString *topicAnchorId = [NSString stringWithFormat:@"sys_chat/%@", anchorId];
    NSData *data = [model mj_JSONData];
    [self.session publishData:data onTopic:topicAnchorId retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
        if (error) {
            NSLog(@"连麦消息发送给主播失败");
        } else {
            NSLog(@"连麦消息发送给主播成功");
        }
    }];
}

- (void)enterOrOutLiveRoom:(BOOL)enter {
    NSString *enterState = enter ? @"进入" : @"离开";
    IMTextModel *model = [[IMTextModel alloc] init];
    model.name = UserInfo[@"nickName"]?UserInfo[@"nickName"]:@"海听用户";
    model.avatar = UserInfo[@"avatar"];
    model.content = [NSString stringWithFormat:@"%@ %@直播间", model.name, enterState];
    model.type = @"进入";
    [[MQTTManager sharedInstance] sendTextMessage:model inChatRoom:self.chatRommId];
}

- (void)rejectLianMaiToAnchor:(NSString *)anchorId {
    IMTextModel *model = [[IMTextModel alloc] init];
    model.name = UserInfo[@"nickName"]?UserInfo[@"nickName"]:@"海听用户";
    model.avatar = UserInfo[@"avatar"];
    model.content = [NSString stringWithFormat:@"%@拒绝连麦", model.name];
    model.type = @"拒绝连麦";
    [[MQTTManager sharedInstance] sendLianMaiMessage:model toAnchor:anchorId];
}

- (void)sendTextToAnchor:(BOOL)apply toAnchor:(NSString *)anchorId {
    IMTextModel *model = [[IMTextModel alloc] init];
    model.type = apply ? @"申请连麦" : @"取消连麦";
    model.name = UserInfo[@"nickName"]?UserInfo[@"nickName"]:@"海听用户";
    model.avatar = UserInfo[@"avatar"];
    model.content = apply ? @"申请连麦" : @"取消连麦";
    [[MQTTManager sharedInstance] sendLianMaiMessage:model toAnchor:anchorId];
}

- (void)sendGiftMessage:(NDGiftModel *)model inChatRoom:(NSString *)chatRoomId {
    NSString *topicChatRoomId = [NSString stringWithFormat:@"sys_chat/%@", chatRoomId];
    if ([chatRoomId isEqualToString:self.chatRommId]) {
        NSData *data = [model mj_JSONData];
        [self.session publishData:data onTopic:topicChatRoomId retain:NO qos:MQTTQosLevelExactlyOnce publishHandler:^(NSError *error) {
            if (error) {
                NSLog(@"礼物信息发送失败");
            } else {
                NSLog(@"礼物信息发送成功");
            }
        }];
    }
}

/*
 * MQTTSessionManagerDelegate
 */
- (void)sessionManager:(MQTTSessionManager *)sessionManager
     didReceiveMessage:(NSData *)data
               onTopic:(NSString *)topic
              retained:(BOOL)retained {
    _getMqttMessageB(data);
}

- (void)newMessage:(MQTTSession *)session
              data:(NSData *)data
           onTopic:(NSString *)topic
               qos:(MQTTQosLevel)qos
          retained:(BOOL)retained
               mid:(unsigned int)mid {
    
    _getMqttMessageB(data);
    NSString *str =[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"收到的str%@",str);

}

- (BOOL)newMessageWithFeedback:(MQTTSession *)session
                          data:(NSData *)data
                       onTopic:(NSString *)topic
                           qos:(MQTTQosLevel)qos
                      retained:(BOOL)retained
                           mid:(unsigned int)mid {
    NSLog(@"2=========");
    return YES;
}


- (void)messageDelivered:(MQTTSession *)session msgID:(UInt16)msgID {
    NSLog(@"3=========");
}

#pragma mark - block
- (void)getMqttPingStatus:(GetMqttPingStatusBlock)block {
    _getMqttPingStatusB = block;
}



- (void)getMqttMessage:(GetMqttMessageBlock)block {
    _getMqttMessageB = block;
}

@end
