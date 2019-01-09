//
//  ViewController.swift
//  CustomLayoutIssue
//
//  Created by Nikita Koltsov on 1/9/19.
//  Copyright © 2019 NKolltsov. All rights reserved.
//

import UIKit
import AsyncDisplayKit

class ViewController: ASViewController<ASCollectionNode>, ASCollectionDelegate, ASCollectionDataSource {

    
    // MARK: Properties
    
    
    let layout: WaterfallLayout
    
    var headerHeight: CGFloat {
        return 0
    }
    
    var provider = DataProvider(pageSize: 20)
    var items: [CellModel] = []
    
    // MARK: Lifecycle
    
    init() {
    
        layout = WaterfallLayout()
        super.init(node: ASCollectionNode(frame: .zero, collectionViewLayout: layout))
//        items = provider.nextItems
        
        
        node.delegate = self
        node.dataSource = self
        layout.delegate = self
        node.layoutInspector = layout
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    func setupViews() {
        node.backgroundColor = .white
    }
    // MARK: Private
    
    private func loadMoreData(_ context: ASBatchContext) {
        
        if provider.hasMore {
            provider.nextItems { [weak self, weak context] items in
                guard let this = self else { return }
                let startIndex = this.items.count
                
                DispatchQueue.main.async {
                    this.items.append(contentsOf: items)
                    this.node.insertItems(at: Array(startIndex..<startIndex+items.count).map { IndexPath(row: $0, section: 0) })
                    context?.completeBatchFetching(true)
                }
                
            }
        }
        
        
    }
    
    // MARK: ASCollectionDelegate
    
    func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
        return provider.hasMore
    }

    func collectionNode(_ collectionNode: ASCollectionNode, willBeginBatchFetchWith context: ASBatchContext) {
        loadMoreData(context)
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, didSelectItemAt indexPath: IndexPath) {
        print("Subnodes count: \(collectionNode.cellForItem(at: indexPath)?.subviews.count ?? 0)")
        print(indexPath)
    }
    
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return items.count
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeForItemAt indexPath: IndexPath) -> ASCellNode {
        let item = items[indexPath.row]
        return CellNode(model: item, index: indexPath.row)
    }
    
    func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return 1
    }
}

// MARK: - GiphyCollectionViewLayoutDelegate
extension ViewController: WaterfallLayoutDelegate {
    func heightForHeader() -> CGFloat {
        return 0
    }
    
    func numberOfItems() -> Int {
        return items.count
    }
    
    func cellHeighForItem(at indexPath: IndexPath, with width: CGFloat) -> CGFloat {
        let item = items[indexPath.row]
        return item.height * (width / item.width)
    }
}
