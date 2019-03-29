# rxswiftPlayer
这是一个音乐播放器，基于swift与rxswift双向绑定架构编写。

# 简易播放器功能
1. 上一曲/下一曲/播放/暂停，
2. 冲进度监控/播放进度监控/播放状态监控。
3. 拖动更改播放进度。

# 结构
ZZAVPlayer：AVPlayer的为播放器，ZZAVPlayer接管与AVPlayer的交互，冲进度监控/播放进度监控/播放状态监控。
ZZAVPlayerView：全面负责UI，UI事件与UI刷新构成ZZAVPlayerVM的Input/Output。弱引用ZZAVPlayer,Player事件与控制在view中发出。
ZZAVPlayerVM：rx的输入输出流，接收事件In，处理后通过Out扔出，V中接收处理后数据刷新UI，VM完全不知道V，解耦。数据请求也放在这里（目前是假请求）
