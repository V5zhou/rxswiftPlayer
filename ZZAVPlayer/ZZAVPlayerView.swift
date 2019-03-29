//
//  ZZAVPlayerView.swift
//  ZZAVPlayer
//
//  Created by zmz on 2019/3/25.
//  Copyright © 2019 zmz. All rights reserved.
//

import AlamofireImage
import RxCocoa
import RxSwift
import UIKit

class ZZAVPlayerView: UIView {
    let bag = DisposeBag()
    weak var player: ZZAVPlayer? {
        didSet {
            if player != nil {
                bind()
            }
        }
    }
    
    deinit {
        endAnimation()
    }

    var vm: ZZAVPlayerVM?
    lazy var translatez: CABasicAnimation = {
        let animate = CABasicAnimation.init(keyPath: "transform.rotation.z")
        animate.fromValue = 0
        animate.toValue = Float.pi * 2
        animate.duration = 10
        animate.timingFunction = CAMediaTimingFunction.init(name: .linear)
        animate.repeatCount = HUGE
        animate.autoreverses = false
        return animate
    }()

    override func awakeFromNib() {
        icon.layer.cornerRadius = 100
        icon.layer.masksToBounds = true
    }

    // MARK: ---------------------- UI ----------------------

    @IBOutlet var refreshBtn: UIButton!
    @IBOutlet var name: UILabel!
    @IBOutlet var artist: UILabel!
    @IBOutlet var icon: UIImageView!
    @IBOutlet var startTime: UILabel!
    @IBOutlet var endTime: UILabel!
    @IBOutlet var progress: UIProgressView!
    @IBOutlet var slider: UISlider!
    @IBOutlet var playBtn: UIButton!
    @IBOutlet var lastBtn: UIButton!
    @IBOutlet var nextBtn: UIButton!
}

extension ZZAVPlayerView {
    func startAnimation() {
        icon.layer.add(translatez, forKey: "translatez")
    }

    func endAnimation() {
        icon.layer.removeAnimation(forKey: "translatez")
    }
}

// in/out
extension ZZAVPlayerView {
    func bind() {
        typealias Input = ZZAVPlayerVM.Input
        guard let player = player else {
            return
        }
        let input = Input(refreshMusics: refreshBtn.rx.tap.asDriver(),
                          lastClick: lastBtn.rx.tap.asDriver(),
                          nextClick: nextBtn.rx.tap.asDriver(),
                          playClick: playBtn.rx.tap.asDriver(),
                          playFinish: player.playFinish,
                          playStatus: player.playStatus,
                          loadedTimeRanges: player.loadedTimeRanges,
                          sliderChanged: slider.rx.value.asObservable().map { CGFloat($0) },
                          playTime: player.playTime)
        vm = ZZAVPlayerVM(input: input)

        guard let output = self.vm?.output else {
            return
        }
        output.musics.drive(onNext: { musics in
            // 音乐列表，可以展示音乐列表栏
            let names = musics?.compactMap({ info -> String? in
                return info?.name
            })
            print("获取音乐列表：\(String(describing: names))")
        }).disposed(by: bag)
        output.playMusic.distinctUntilChanged({ (truple0, truple1) -> Bool in
            truple0.0 == truple1.0 && truple0.1 == truple1.1
        }).drive(onNext: { [unowned self] truple in
            let isPlay = truple.0
            self.playBtn.isSelected = isPlay

            guard let info = truple.1 else {
                return
            }
            self.name.text = info.name
            self.artist.text = info.artist
            self.icon.af_setImage(withURL: URL(string: info.cover ?? "")!)
            self.endTime.text = info.duration
            if isPlay {
                self.endAnimation()
                self.player?.play(info: info)
                self.startAnimation()
            } else {
                self.player?.pause()
            }
        }).disposed(by: bag)

        // 加载进度
        output.loadProgress.drive(onNext: { [unowned self] value in
            self.progress.progress = value
        }).disposed(by: bag)

        // 播放进度
        output.playProgress.drive(onNext: { [weak self] truple in
            self?.startTime.text = String(format: "%02d:%02d", Int(truple.2) / 60, Int(truple.2) % 60)
            self?.slider.value = Float(truple.1)
            if truple.0 {
                self?.player?.slider(to: Float(truple.2))
            }
            print("playProgress:\(truple.1)")
        }).disposed(by: bag)
    }
}
