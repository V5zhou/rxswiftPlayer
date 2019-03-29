//
//  ZZAVPlayerVM.swift
//  ZZAVPlayer
//
//  Created by zmz on 2019/3/26.
//  Copyright © 2019 zmz. All rights reserved.
//

import AVFoundation
import RxCocoa
import RxSwift
import UIKit

// input output
class ZZAVPlayerVM: NSObject {
    // MARK: ---------------------- In Out ----------------------

    struct Input {
        var refreshMusics: Driver<Void> // 点击刷新列表
        var lastClick: Driver<Void> // 点击上一曲
        var nextClick: Driver<Void> // 点击下一曲
        var playClick: Driver<Void> // 点击播放/暂停
        var playFinish: Driver<Void> // 播放完成监控
        var playStatus: PublishSubject<Observable<AVPlayer.Status?>> // 播放状态监控
        var loadedTimeRanges: PublishSubject<Observable<NSArray?>> // 加载进度监控
        var sliderChanged: Observable<CGFloat> // 滑动slider
        var playTime: Observable<(CGFloat, CGFloat)> // 播放进度监控  (progress, time)
    }

    struct Output {
        var musics: Driver<[ZZAVPlayerInfo?]?>
        var playMusic: Driver<(Bool, ZZAVPlayerInfo?)>
        var loadProgress: Driver<Float>
        var playProgress: Driver<(Bool, CGFloat, CGFloat)> // (isSeek, progress, time)
    }

    var input: Input
    var output: Output?

    // MARK: ---------------------- 其它 ----------------------

    var musics: [ZZAVPlayerInfo?]?
    var index: Int?
    var isPlaying = false /// < 是否正在播放
    var music: ZZAVPlayerInfo? {
        guard let index = index else {
            return nil
        }
        guard musics?.count ?? 0 > index else {
            return nil
        }
        return musics?[index]
    }

    required init(input: Input) {
        self.input = input
        super.init()
        output = exchange(input: input)
    }
}

// logic
extension ZZAVPlayerVM {
    func exchange(input: Input) -> Output {
        // --------- 请求列表数据
        let musics = input.refreshMusics.flatMap { self.fetchMusics() }

        // --------- 播放/暂停/上/下一曲状态/播放完成/列表加载完成自动播放第一个/播放失败监控
        func changeIndex(offset: Int) {
            guard let index = self.index, let count = self.musics?.count, count > 0 else {
                isPlaying = false
                return
            }
            self.index = (index + count + offset) % count
            isPlaying = true
        }
        let last = input.lastClick.map { changeIndex(offset: -1) }
        let next = input.nextClick.map { changeIndex(offset: 1) }
        let finish = input.playFinish.map { changeIndex(offset: 1) }
        let first = musics.map { [unowned self] list in
            guard let list = list, list.count > 0 else {
                return
            }
            // 默认刷新一次列表，就把歌曲设置为第0首
            self.index = 0
            self.isPlaying = true
        }
        let playClick = input.playClick.map { [unowned self] _ in
            guard let _ = self.index else {
                self.isPlaying = false
                return
            }
            self.isPlaying = !self.isPlaying
        }
        let statusChange = input.playStatus.flatMapLatest { $0 }
            .map { status -> Void in
                let status = status ?? .unknown
                switch status {
                case .failed:
                    print("加载失败")
                    self.isPlaying = false
                case .readyToPlay:
                    print("准备播放")
                case .unknown:
                    print("未知状态")
                }
            }.asDriver(onErrorJustReturn: ())

        let playMusic = Driver.of(last, next, finish, first, playClick, statusChange).merge().map { [unowned self] _ -> (Bool, ZZAVPlayerInfo?) in
            return (self.isPlaying, self.music)
        }

        // --------- 缓冲状态
        let loadProgress = input.loadedTimeRanges.flatMap { $0 }.map { [weak self] (times) -> Float in
            guard let range = times?.firstObject as? CMTimeRange else {
                return 0
            }
            guard let total = self?.music?.durationSecond else {
                return 0
            }
            let progress = range.duration.seconds / Double(total)
            print("load:\(progress)")
            return Float(progress)
        }.asDriver(onErrorJustReturn: 0)

        // --------- 播放进度
        let sliderProgress = input.sliderChanged.map { [weak self] (progress) -> (Bool, CGFloat, CGFloat) in
            return (true, progress, progress * CGFloat(self?.music?.durationSecond ?? 0))
        }
        let playTime = input.playTime.map { (truple) -> (Bool, CGFloat, CGFloat) in
            return (false, truple.0, truple.1)
        }
        let playProgress = Observable.of(sliderProgress, playTime).merge().asDriver(onErrorJustReturn: (false, 0, 0))

        let out = Output(musics: musics, playMusic: playMusic, loadProgress: loadProgress, playProgress: playProgress)
        return out
    }
}

// api
extension ZZAVPlayerVM {
    func fetchMusics() -> Driver<[ZZAVPlayerInfo?]?> {
        // 这里写请求，本地数据模拟了下
        musics = ZZAVPlayerInfo.urlMusics()
        index = (musics?.count ?? 0 > 0) ? 0 : nil
        return Driver<[ZZAVPlayerInfo?]?>.just(musics)
    }
}
