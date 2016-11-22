//
//  ReadLaterTableViewController.swift
//  News
//
//  Created by James Wilkinson on 22/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class ReadLaterTableViewController: ArticlesTableViewController {

    override var state: StateController.State! {
        return .readLater
    }
    
    override var allowedSwipeOptions: ArticleTableViewCell.ActionOptions! {
        return ArticleTableViewCell.ActionOptions(left: nil, right: .discard)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupSubscriptionToStateController() {
        StateController.instance.subscribe(to: .readLater) {
            switch $0 {
            case .preloaded(let articles):
                self.data = articles
                self.reloadTableView()
            case .error(_):
                self.data = []
                self.reloadTableView()
            case .downloading:
                break
            case .loaded(let articles):
                self.data = articles
                self.reloadTableView()
            }
        }
    }
    
    override func reloadData() {
        StateController.instance.loadReadLaterArticles()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func configure(_ cell: ArticleTableViewCell, for indexPath: IndexPath) {
        cell.headline.text = data[indexPath.row].title
        cell.source.text = data[indexPath.row].source
    }
}
