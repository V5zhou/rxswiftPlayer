//
//  ZZAVPlayerInfo.swift
//  ZZAVPlayer
//
//  Created by zmz on 2019/3/25.
//  Copyright © 2019 zmz. All rights reserved.
//

import UIKit
import HandyJSON

struct ZZAVPlayerInfo: HandyJSON, Equatable {
    var id: String? /// < 歌曲编号
    var name: String? /// < 歌曲名
    var artist: String? /// < 歌曲作者
    var cover: String? /// < 封面
    var duration: String? /// < 时长
    var url: String? /// < 链接

    /// 时长多少s
    var durationSecond: NSInteger {
        guard duration != nil, duration!.contains(":") else {
            return 0
        }
        let ms = duration!.components(separatedBy: ":")
        guard ms.count > 1 else {
            return 0
        }
        return (NSInteger(ms[0]) ?? 0) * 60 + (NSInteger(ms[1]) ?? 0)
    }
    
    //MARK: ---------------------- Test ----------------------
    static func urlMusics() -> [ZZAVPlayerInfo?]? {
        guard let path = Bundle.main.path(forResource: "music", ofType: "json") else {
            return nil
        }
        guard let data = try? Data.init(contentsOf: URL.init(fileURLWithPath: path)) else {
            return nil
        }
        guard let datas = try? JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [Any] else {
            return nil
        }
        let infos = [ZZAVPlayerInfo].deserialize(from: datas)
        return infos
    }
}
