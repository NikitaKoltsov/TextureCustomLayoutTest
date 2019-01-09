//
//  DataProvider.swift
//  CustomLayoutIssue
//
//  Created by Nikita Koltsov on 1/9/19.
//  Copyright © 2019 NKolltsov. All rights reserved.
//

import Foundation
import UIKit

class DataProvider {
    
    private var page = 0
    private var maxPages = 10
    
    var hasMore: Bool { return page < maxPages }
    var pageSize: Int
    
    init(pageSize: Int) {
        self.pageSize = pageSize
    }
    
    var nextItems: [CellModel] {
        return Array(0..<pageSize).map { _ in CellModel.random() }

    }
    
    func nextItems(completion: @escaping (([CellModel]) -> Void)) {
        guard hasMore else { return }
        
        completion(nextItems)
        page += 1
    }
}
