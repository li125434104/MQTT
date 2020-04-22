//
//  MQTTManager.h
//  HaiTing
//
//  Created by taishu on 2020/3/16.
//  Copyright © 2020 taishu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MQTTClient/MQTTClient.h>
#import <MQTTClient/MQTTSessionManager.h>
#import "IMTextModel.h"
#import "NDGiftModel.h"

NS_ASSUME_NONNULL_BEGIN

typedef void(^GetMqttPingStatusBlock)(NSString *strState);
typedef void(^GetMqttMessageBlock)(NSData *messageData);

@interface MQTTManager : NSObject

@property (nonatomic, copy) GetMqttPingStatusBlock getMqttPingStatusB;
@property (nonatomic, copy) GetMqttMessageBlock getMqttMessageB;

+ (MQTTManager *)sharedInstance;

//初始化
- (void)startMqtt;

//断开连接
- (void)disMQTTConnect;

//获取mqtt连接状态
- (MQTTSessionStatus)getMqttStatus;

//添加主题
- (void)addTopicWithName:(NSString *)strTopic;

/// 订阅直播间ID
/// @param chatRoomId 直播间ID
/// @param result 返回结果
- (void)subscribeChatRomm:(NSString *)chatRoomId resultBlcok:(void(^)(BOOL success))result;

/// 取消订阅
/// @param chatRoomId 直播间ID
/// @param result 返回结果
- (void)unsubscribeChatRoom:(NSString *)chatRoomId resultBlcok:(void(^)(BOOL success))result;

//订阅自己，接收主播连麦消息
- (void)subscribeMineResultBlock:(void(^)(BOOL success))result;

//取消订阅自己
- (void)unsubscribeMineResultBlock:(void(BOOL success))result;

/// 在直播间中发送群聊消息
/// @param model 发送的model
/// @param chatRoomId 直播间ID
- (void)sendTextMessage:(IMTextModel *)model inChatRoom:(NSString *)chatRoomId;

/// 发送连麦消息给主播
/// @param model 发送的model
/// @param anchorId 主播ID
- (void)sendLianMaiMessage:(IMTextModel *)model toAnchor:(NSString *)anchorId;

/// 发送进入或者离开直播间消息
/// @param enter YES是进入  NO是离开
- (void)enterOrOutLiveRoom:(BOOL)enter;

/// 发送拒绝连麦消息给主播
/// @param anchorId 主播ID
- (void)rejectLianMaiToAnchor:(NSString *)anchorId;

/// 发送申请连麦或者取消连麦消息给主播
/// @param apply 申请yes 取消no
/// @param anchorId 主播ID
- (void)sendTextToAnchor:(BOOL)apply toAnchor:(NSString *)anchorId;

/// 发送礼物消息到直播间
/// @param model 礼物model
/// @param chatRoomId 直播间ID
- (void)sendGiftMessage:(NDGiftModel *)model inChatRoom:(NSString *)chatRoomId;

//block
- (void)getMqttPingStatus:(GetMqttPingStatusBlock)block;
- (void)getMqttMessage:(GetMqttMessageBlock)block;

@end

NS_ASSUME_NONNULL_END
