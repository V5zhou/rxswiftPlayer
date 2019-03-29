//
//  ViewController.swift
//  ZZAVPlayer
//
//  Created by zmz on 2019/3/25.
//  Copyright © 2019 zmz. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(player.view!)
        player.view?.frame = UIScreen.main.bounds
    }
    
    lazy var player: ZZAVPlayer = {
        return ZZAVPlayer()
    }()
}

