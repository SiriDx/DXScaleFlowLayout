//
//  DXScaleFlowLayout.swift
//  DXScaleFlowLayout
//
//  Created by Dean on 2018/10/15.
//  Copyright © 2018年 SiriDx. All rights reserved.
//  代码地址: https://github.com/SiriDx/DXScaleFlowLayout

import UIKit

/*
extension UICollectionView {
    
    open func scaleScroll(toIndex index:Int, animated:Bool = false) {
        
        if index < 0 || index > numberOfItems(inSection: 0) - 1 {
            return
        }
        
        guard let scaleLayout = collectionViewLayout as? DXScaleFlowLayout else { return }
        
        DispatchQueue.main.async {
            let totalDis = scaleLayout.itemSize.width + scaleLayout.minimumLineSpacing
            let newOffsetX = totalDis * CGFloat(index) - self.contentInset.left
            self.setContentOffset(CGPoint(x: newOffsetX, y: self.contentOffset.y), animated: animated)
            self.layoutIfNeeded()
        }
    }
    
}
*/
 
open class DXScaleFlowLayout: UICollectionViewFlowLayout {
    
    open var isPagingEnabled: Bool = true
    open var transformScale: CGFloat = 1
    open var minimumAlpha: CGFloat = 1
    
    private var isFirstLayout:Bool = true
    
    override open func prepare() {
        super.prepare()
        if isFirstLayout {
            resetLayout()
            isFirstLayout = false
        }
    }
    
    private func resetLayout() {
        
        if minimumAlpha > 1 || minimumAlpha < 0 {
            minimumAlpha = 1
        }
        
        scrollDirection = .horizontal
        minimumInteritemSpacing = 0
        
        if let collectionView = self.collectionView {
            let clvW = collectionView.frame.size.width
            let insetLeftRight = (clvW - itemSize.width) * 0.5
            var inset = collectionView.contentInset
            inset.left = insetLeftRight
            inset.right = insetLeftRight
            collectionView.contentInset = inset
            
            if isPagingEnabled {
                collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            }
            
            let offsetW = itemSize.width * transformScale * 0.5
            let newSpacing = minimumLineSpacing - offsetW
            
            minimumLineSpacing = newSpacing
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if let attributes = super.layoutAttributesForElements(in: rect),
            let collectionView = self.collectionView {
            
            let visibleRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.frame.size.width, height: collectionView.frame.size.height)
            
            guard let copyAttributes = NSArray.init(array: attributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
            
            let newAttributes = copyAttributes.map { (attribute) -> UICollectionViewLayoutAttributes in
                
                attribute.transform = CGAffineTransform.init(scaleX: 0, y: 0)
                
                if visibleRect.intersects(attribute.frame) {
                    
                    let contentOffsetX = collectionView.contentOffset.x
                    let collectionViewCenterX = collectionView.bounds.size.width * 0.5
                    
                    let centerX = attribute.center.x
                    let distance = abs(centerX - contentOffsetX - collectionViewCenterX)
                    
                    let totalDistance = itemSize.width + minimumLineSpacing
                    
                    let ratio:CGFloat = transformScale
                    
                    let newW = itemSize.width - itemSize.width * ratio
                    let offsetW = abs((totalDistance - distance) / totalDistance * (newW - itemSize.width))
                    
                    let scale = (newW + offsetW) / itemSize.width
                    
                    attribute.alpha = minimumAlpha + ((1 - minimumAlpha) / totalDistance) * (totalDistance - distance)
                    
                    attribute.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                    attribute.zIndex = Int(scale * 10)
                }
                
                return attribute
            }
            
            return newAttributes
        }
        return nil
    }
    
    override open func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override open func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
        
        if isPagingEnabled == false {
            return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
        }
        
        if let collectionView = self.collectionView {
            
            let lastRect = CGRect(x: proposedContentOffset.x, y: proposedContentOffset.y, width: collectionView.frame.size.width, height: collectionView.frame.size.height)
            
            let centerX = proposedContentOffset.x + collectionView.frame.size.width * 0.5;
            
            if let attributes = self.layoutAttributesForElements(in: lastRect) {
                
                var adjustOffsetX = CGFloat(MAXFLOAT);
                for att in attributes {
                    let offsetX = abs(att.center.x - centerX)
                    if offsetX < abs(adjustOffsetX) {
                        adjustOffsetX = att.center.x - centerX;
                    }
                }
                
                var newProposedContentOffsetX = proposedContentOffset.x + adjustOffsetX
                
                let maxOffsetX = collectionView.contentSize.width - collectionView.frame.size.width + collectionView.contentInset.left
                
                if newProposedContentOffsetX > maxOffsetX {
                    newProposedContentOffsetX = maxOffsetX
                }
                
                return CGPoint(x: newProposedContentOffsetX, y: proposedContentOffset.y)
            }
        }
        
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
}
