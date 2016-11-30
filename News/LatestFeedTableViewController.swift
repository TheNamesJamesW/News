//
//  LatestFeedTableViewController.swift
//  News
//
//  Created by James Wilkinson on 21/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class LatestFeedTableViewController: ArticlesTableViewController {
    
    override var state: StateController.State! {
        return .latest
    }
    
    override var allowedSwipeOptions: ArticleTableViewCell.ActionOptions! {
        return ArticleTableViewCell.ActionOptions(left: .discard, right: .readLater)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let refresh = UIRefreshControl()
        refresh.addTarget(self, action: #selector(refreshTable(_:)), for: .valueChanged)
        self.refreshControl = refresh
    }
    
    override func setupSubscriptionToStateController() {
        StateController.instance.subscribe(to: .latest) {
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
                if let refreshControl = self.refreshControl, refreshControl.isRefreshing {
                    refreshControl.endRefreshing()
                }
            }
        }
    }
    
    override func reloadData() {
        StateController.instance.downloadFeedArticles()
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
    
    @objc private func refreshTable(_ sender: UIRefreshControl?) {
        StateController.instance.downloadFeedArticles() // Triggers subscribe update
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
