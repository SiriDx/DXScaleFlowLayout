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
            switch scaleLayout.scrollDirection {
                
            case .horizontal:
                let totalDis = scaleLayout.itemSize.width + scaleLayout.minimumLineSpacing
                let newOffsetX = totalDis * CGFloat(index) - self.contentInset.left
                self.setContentOffset(CGPoint(x: newOffsetX, y: self.contentOffset.y), animated: animated)
                
            case .vertical:
                let totalDis = scaleLayout.itemSize.height + scaleLayout.minimumInteritemSpacing
                let newOffsetY = totalDis * CGFloat(index) - self.contentInset.top
                self.setContentOffset(CGPoint(x: self.contentOffset.x, y: newOffsetY), animated: animated)
                
            }
            self.layoutIfNeeded()
        }
    }
    
}
*/
 
open class DXScaleFlowLayout: UICollectionViewFlowLayout {
    
    open var isPagingEnabled: Bool = true
    open var transformScale: CGFloat = 1
    
    private var isFirstLayout:Bool = true
    
    override open func prepare() {
        super.prepare()
        if isFirstLayout {
            resetLayout()
            isFirstLayout = false
        }
    }
    
    private func resetLayout() {
        
        if let collectionView = self.collectionView {
            let clvW = collectionView.frame.size.width
            let clvH = collectionView.frame.size.height
            
            var inset = collectionView.contentInset
            
            if scrollDirection == .horizontal {
                
                let insetLeftRight = (clvW - itemSize.width) * 0.5
                inset.left = insetLeftRight
                inset.right = insetLeftRight
                collectionView.contentInset = inset
                
                let offsetW = itemSize.width * transformScale * 0.5
                let newSpacing = minimumLineSpacing - offsetW
                minimumLineSpacing = newSpacing
                
            } else if scrollDirection == .vertical {
                
                let insetTopBottom = (clvH - itemSize.height) * 0.5
                inset.top = insetTopBottom
                inset.bottom = insetTopBottom
                collectionView.contentInset = inset
                
                let offsetH = itemSize.height * transformScale * 0.5
                let newSpacing = minimumInteritemSpacing - offsetH
                minimumInteritemSpacing = newSpacing
            }
            
            if isPagingEnabled {
                collectionView.decelerationRate = UIScrollViewDecelerationRateFast
            }
        }
    }
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        if let attributes = super.layoutAttributesForElements(in: rect),
            let collectionView = self.collectionView {
            
            let visibleRect = CGRect(x: collectionView.contentOffset.x, y: collectionView.contentOffset.y, width: collectionView.frame.size.width, height: collectionView.frame.size.height)
            
            guard let copyAttributes = NSArray.init(array: attributes, copyItems: true) as? [UICollectionViewLayoutAttributes] else { return nil }
            
            let newAttributes = copyAttributes.map { (attribute) -> UICollectionViewLayoutAttributes in
                
                if visibleRect.intersects(attribute.frame) {
                    
                    let scale = scrollDirection == .horizontal ? horizontalScale(collectionView, attribute) : verticalScale(collectionView, attribute)
                    attribute.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                    
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
                
                let newProposedContentOffsetX = proposedContentOffset.x + adjustOffsetX
                
                return CGPoint(x: newProposedContentOffsetX, y: proposedContentOffset.y)
            }
        }
        
        return super.targetContentOffset(forProposedContentOffset: proposedContentOffset, withScrollingVelocity: velocity)
    }
    
}

extension DXScaleFlowLayout {
    private func horizontalScale(_ collectionView:UICollectionView, _ attribute:UICollectionViewLayoutAttributes) -> CGFloat {
        
        let contentOffsetX = collectionView.contentOffset.x
        let collectionViewCenterX = collectionView.bounds.size.width * 0.5
        
        let centerX = attribute.center.x
        let distance = abs(centerX - contentOffsetX - collectionViewCenterX)
        
        let totalDistance = itemSize.width + minimumLineSpacing
        
        let ratio:CGFloat = transformScale
        
        let newW = itemSize.width - itemSize.width * ratio
        let offsetW = abs((totalDistance - distance) / totalDistance * (newW - itemSize.width))
        
        let scale = (newW + offsetW) / itemSize.width
        return scale
    }
    
    private func verticalScale(_ collectionView:UICollectionView, _ attribute:UICollectionViewLayoutAttributes) -> CGFloat {
        
        let contentOffsetY = collectionView.contentOffset.y
        let collectionViewCenterY = collectionView.bounds.size.height * 0.5
        
        let centerY = attribute.center.y
        let distance = abs(centerY - contentOffsetY - collectionViewCenterY)
        
        let totalDistance = itemSize.height + minimumInteritemSpacing
        
        let ratio:CGFloat = transformScale
        
        let newH = itemSize.height - itemSize.height * ratio
        let offsetH = abs((totalDistance - distance) / totalDistance * (newH - itemSize.height))
        
        let scale = (newH + offsetH) / itemSize.height
        return scale
    }
}
