//
//  ViewController.swift
//  Example
//
//  Created by Dean on 2018/10/15.
//  Copyright © 2018年 SiriDx. All rights reserved.
//

import UIKit

import UIKit
import DXScaleFlowLayout

class ViewController: UIViewController {
    
    private var collectionView:UICollectionView!
    private var scaleLayout:DXScaleFlowLayout!
    
    private lazy var datas:[String] = {
        var images = [String]()
        for i in 1...5 {
            images.append("card_board_G\(i)")
        }
        return images
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        setupLayout()
        setupCollectionView()
        
        collectionView.scaleScroll(toIndex: 2)
    }
    
    func setupLayout() {
        let layout = DXScaleFlowLayout()
        self.scaleLayout = layout
        layout.isPagingEnabled = true
        layout.transformScale = (300 - 250) / 300.0
        layout.minimumLineSpacing = 10
        
        let itemW:CGFloat = 570 * 0.5 + 20
        let itemH:CGFloat = (388.0 / 706.0) * itemW
        layout.itemSize = CGSize(width: itemW, height: itemH)
    }
    
    func setupCollectionView() {
        
        let kScreenW = UIScreen.main.bounds.size.width
        let kScreenH = UIScreen.main.bounds.size.height
        
        let clvH:CGFloat = 170.0
        let clvY = (kScreenH - clvH) * 0.5
        let rect = CGRect(x: 0, y: clvY, width: kScreenW, height: clvH)
        
        let collectionView = UICollectionView(frame: rect, collectionViewLayout: scaleLayout)
        self.collectionView = collectionView
        collectionView.showsHorizontalScrollIndicator = false
        
        self.collectionView = collectionView
        view.addSubview(collectionView)
        collectionView.backgroundColor = UIColor.white
        
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.register(ExampleCell.self, forCellWithReuseIdentifier: "cell")
    }
    
}

extension ViewController:UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datas.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! ExampleCell
        cell.bgImageView.image = UIImage.init(named: datas[indexPath.row])
        return cell
    }
}

class ExampleCell: UICollectionViewCell {
    
    var bgImageView:UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        let bgImageView = UIImageView()
        contentView.addSubview(bgImageView)
        self.bgImageView = bgImageView
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        bgImageView.frame = bounds
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

