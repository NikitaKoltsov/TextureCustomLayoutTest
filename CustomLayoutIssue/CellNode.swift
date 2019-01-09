//
//  CellNode.swift
//  CustomLayoutIssue
//
//  Created by Nikita Koltsov on 1/9/19.
//  Copyright © 2019 NKolltsov. All rights reserved.
//

import Foundation
import AsyncDisplayKit

struct CellModel {
    
    private static let colors: [UIColor] = [.red, .orange, .blue, .green, .yellow, .cyan]
    private static let height: [CGFloat] = [200, 100, 120, 60, 180, 90, 156]
    private static let width: [CGFloat] = [100, 80, 130, 300, 200, 150]
    
    let color: UIColor
    let width: CGFloat
    let height: CGFloat
    
    
    static func random() -> CellModel {
        
        let color = colors[Int.random(in: 0..<colors.count)]
        let height = self.height[Int.random(in: 0..<self.height.count)]
        let width = self.width[Int.random(in: 0..<self.width.count)]
        return CellModel(color: color, width: width, height: height)
    }
}

class CellNode: ASCellNode {
    
    
    let contentNode = ASDisplayNode()
    let textNode = ASTextNode()
    
    // MARK: Lifecycle
    
    init(model: CellModel, index: Int) {
        
        
        super.init()
        configureSubnodes()
        contentNode.backgroundColor = model.color
        textNode.attributedText = NSAttributedString(
            string: "\(index)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 30),
                                           NSAttributedString.Key.foregroundColor: UIColor.black])
    }
    
    
    override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        let centerSpec = ASCenterLayoutSpec(horizontalPosition: .center, verticalPosition: .center, sizingOption: [], child: textNode)
        let backgroundSpec = ASBackgroundLayoutSpec(child: centerSpec, background: contentNode)
        
        return backgroundSpec
    }
    
    // MARK: Private
    
    private func configureSubnodes() {
        addSubnode(contentNode)
        addSubnode(textNode)
    }
    
}
