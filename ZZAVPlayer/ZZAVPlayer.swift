//
//  ZZAVPlayer.swift
//  ZZAVPlayer
//
//  Created by zmz on 2019/3/25.
//  Copyright © 2019 zmz. All rights reserved.
//

import AVFoundation
import RxCocoa
import RxSwift
import UIKit

class ZZAVPlayer: NSObject {

    // MARK: ---------------------- 播放器 ----------------------

    lazy var player: AVPlayer = {
        // item会在播放时替换掉
        let item = AVPlayerItem(url: URL(fileURLWithPath: ""))
        ZZAVPlayer.activeAudioSession()
        return AVPlayer(playerItem: item)
    }()

    lazy var view: ZZAVPlayerView? = {
        guard let v = Bundle.main.loadNibNamed("ZZAVPlayerView", owner: self, options: nil)?.first as? ZZAVPlayerView else {
            return nil
        }
        v.player = self
        return v
    }()
    
    //MARK: ---------------------- 对外事件 ----------------------
    // 播放完成通知
    lazy var playFinish: Driver<Void> = {
        NotificationCenter.default.rx.notification(.AVPlayerItemDidPlayToEndTime).map{_ in }.asDriver(onErrorJustReturn: ())
    }()
    /// 播放进度 (progress, time)
    lazy var playTime: Observable<(CGFloat, CGFloat)> = {
        return .create({ [unowned self] (observer) -> Disposable in
            let timeKvo = self.player.addPeriodicTimeObserver(forInterval: CMTime.init(value: 1, timescale: 1), queue: DispatchQueue.main, using: { (time) in
                let current = time.seconds
                let progress = time.seconds/self.player.currentItem!.duration.seconds
                observer.onNext((CGFloat(progress), CGFloat(current)))
            })
            return Disposables.create {
                self.player.removeTimeObserver(timeKvo)
            }
        })
    }()
    // 播放器状态
    lazy var playStatus: PublishSubject<Observable<AVPlayer.Status?>> = {
        PublishSubject()
    }()
    // 音乐缓冲状态
    lazy var loadedTimeRanges: PublishSubject<Observable<NSArray?>> = {
        PublishSubject()
    }()

    // MARK: ---------------------- 设置音频会话 ----------------------

    class func activeAudioSession() {
        let session = AVAudioSession.sharedInstance()
        do {
            // 设置类型为播放，option为允许蓝牙
            try session.setCategory(.playback, mode: .default, options: .allowBluetooth)
        } catch {
            print(error.localizedDescription)
        }
        do {
            // 激活音频会话
            try session.setActive(true, options: .notifyOthersOnDeactivation)
        } catch {
            print(error.localizedDescription)
        }
    }
}

extension ZZAVPlayer {
    // MARK: ---------------------- 播放与暂停 ----------------------

    func play(list: [ZZAVPlayerInfo?]?) {
        guard let list = list, list.isEmpty else {
            return
        }
        play(info: list.first!)
    }

    func play(info: ZZAVPlayerInfo?) {
        guard let info = info, let url = info.url, let URL = URL(string: url) else {
            return
        }
        // 如果是同一曲，就别换源重新缓冲了
        if let asset = player.currentItem?.asset as? AVURLAsset, asset.url.absoluteString == info.url {
            player.play()
            return
        }
        // 开始播放新的一曲
        let item = AVPlayerItem(url: URL)
        player.replaceCurrentItem(with: item)
        player.play()
        self.playStatus.onNext(self.player.currentItem!.rx.observeWeakly(AVPlayer.Status.self, "status").observeOn(MainScheduler.asyncInstance))
        self.loadedTimeRanges.onNext(self.player.currentItem!.rx.observe(NSArray.self, "loadedTimeRanges").observeOn(MainScheduler.asyncInstance))
    }

    func pause() {
        player.pause()
    }
    
    func slider(to: Float) {
        player.pause()
        let time = CMTime.init(value: CMTimeValue(to), timescale: 1)
        player.seek(to: time) { [weak self] (finished) in
            if finished {
                self?.player.play()
            }
        }
    }
}
