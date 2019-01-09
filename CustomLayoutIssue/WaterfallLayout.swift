//
//  WaterfallLayout.swift
//  CustomLayoutIssue
//
//  Created by Nikita Koltsov on 1/9/19.
//  Copyright © 2019 NKolltsov. All rights reserved.
//


import UIKit
import AsyncDisplayKit

protocol WaterfallLayoutDelegate: class {
    
    func cellHeighForItem(at indexPath: IndexPath, with width: CGFloat) -> CGFloat
    func numberOfItems() -> Int
}

class WaterfallLayout: UICollectionViewLayout {
    
    weak var delegate: WaterfallLayoutDelegate?
    
    private var cache: [UICollectionViewLayoutAttributes] = []
    
    private var contentHeight: CGFloat = 0
    private var columnWidth: CGFloat = 0
    private let inset: CGFloat = 12
    private let numberOfColumns = 2
    
    private var yOffset: [CGFloat] = []
    
    func forceInvalidateLayout() {
        cache = []
        contentHeight = 0
        columnWidth = 0
    }
    
    // MARK: - UICollectionViewLayout
    
    override func invalidateLayout() {
        super.invalidateLayout()
        forceInvalidateLayout()
    }
    
    override func prepare() {
        super.prepare()
        
        if cache.count == 0 {
            prepareLayoutFromScratch()
        } else {
            prepareLayoutForInsertedItems()
        }
    }
    
    override var collectionViewContentSize: CGSize {
        return CGSize(width: 2*columnWidth + 3*inset, height: contentHeight)
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visibleLayoutAttributes: [UICollectionViewLayoutAttributes] = []
        
        for attributes in cache {
            if attributes.frame.intersects(rect) {
                visibleLayoutAttributes.append(attributes)
            }
        }
        
        return visibleLayoutAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return cache[indexPath.item]
    }
    
    // MARK: - Private
    
    private func prepareLayoutFromScratch() {
        guard let collectionView = collectionView,
            let numberOfItems = delegate?.numberOfItems(),
            numberOfItems > 0,
            collectionView.numberOfSections > 0 else {
                return
        }
        
        cache = []
        columnWidth = (collectionView.bounds.width - 3*inset) / 2
        
        let xOffset: [CGFloat] = [inset, columnWidth + 2*inset]
        yOffset = [0, 0]

        
        // items
        
        for item in 0 ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let column = yOffset[0] > yOffset[1] ? 1 : 0
            
            let itemHeight = delegate?.cellHeighForItem(at: indexPath, with: columnWidth) ?? 0
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: itemHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY) + inset
            yOffset[column] = yOffset[column] + itemHeight + inset
        }
        
    }
    
    private func prepareLayoutForInsertedItems() {
        guard let numberOfItems = delegate?.numberOfItems(), numberOfItems > cache.count else {
            return
        }
        
        let xOffset: [CGFloat] = [inset, columnWidth + 2*inset]
        
        for item in cache.count ..< numberOfItems {
            let indexPath = IndexPath(item: item, section: 0)
            let column = yOffset[0] > yOffset[1] ? 1 : 0
            
            let itemHeight = delegate?.cellHeighForItem(at: indexPath, with: columnWidth) ?? 0
            let frame = CGRect(x: xOffset[column], y: yOffset[column], width: columnWidth, height: itemHeight)
            
            let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
            attributes.frame = frame
            cache.append(attributes)
            
            contentHeight = max(contentHeight, frame.maxY) + inset
            yOffset[column] = yOffset[column] + itemHeight + inset
        }
    }
}

extension WaterfallLayout: ASCollectionViewLayoutInspecting {
    
    func collectionView(_ collectionView: ASCollectionView, constrainedSizeForNodeAt indexPath: IndexPath) -> ASSizeRange {
        guard indexPath.item < cache.count else {
            return ASSizeRange(min: .zero, max: .zero)
        }
        
        let size = cache[indexPath.item].size
        return ASSizeRangeMake(size, size)
    }
    
    func scrollableDirections() -> ASScrollDirection {
        return ASScrollDirectionVerticalDirections
    }
    
    
}
