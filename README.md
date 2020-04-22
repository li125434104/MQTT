# MQTT
项目中MQTT的总结

### 一、使用第三方库MQTTClient
### 二、实现了基础的IM功能
### 三、基本步骤
* 1、连接MQTT服务器，这里注意clientId这个参数应该是随机的，MQTTClient里面如果不传就默认随机，否则例如阿里云的就会认定为同一用户进行互踢
* 2、订阅某个主题，例如这里需要实现群聊和单聊，群聊则订阅聊天室ID的主题，单聊则订阅自己的主题
* 3、发送信息。向相应的主题里发送信息即可，比如单聊就是向对方的ID那个主题里发送信息

### 相应的文档
* https://www.jianshu.com/p/d442b70e92b5
* https://blog.csdn.net/ismilesky/article/details/76906763
* https://blog.csdn.net/robinson_911/article/details/70477886
* https://www.jianshu.com/p/38e8cf68796c
* https://www.jianshu.com/p/80ea4507ca74
