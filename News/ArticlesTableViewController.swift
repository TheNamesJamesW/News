//
//  ArticlesTableViewController.swift
//  News
//
//  Created by James Wilkinson on 22/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class ArticlesTableViewController: UITableViewController {
    
    var data: [Article] = []
    
    var state: StateController.State! {
        assertionFailure("This should be overriden")
        return nil
    }
    
    var allowedSwipeOptions: ArticleTableViewCell.ActionOptions! {
        assertionFailure("This should be overriden")
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "article")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        setupSubscriptionToStateController()
        
        self.reloadData()
    }
    
    func setupSubscriptionToStateController() {
        assertionFailure("This should be overriden")
    }
    
    func reloadData() {
        assertionFailure("This should be overriden")
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadSections([0], with: .top)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath) as! ArticleTableViewCell
        
        cell.delegate = self
        cell.state = self.state
        cell.swipeOptions = self.allowedSwipeOptions
        
        configure(cell, for: indexPath)
        
        return cell
    }
    
    func configure(_ cell: ArticleTableViewCell, for indexPath: IndexPath) {
        assertionFailure("This should be overriden")
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

extension ArticlesTableViewController: ArticleTableViewCellDelegate {
    func articleCell(_ cell: ArticleTableViewCell, didCommit action: ArticleTableViewCell.Action) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let article = data.remove(at: indexPath.row)
        
        switch action {
        case .readLater:
            self.tableView.deleteRows(at: [indexPath], with: .top)
            StateController.instance.readLater(article)
            
        case .discard:
            self.tableView.deleteRows(at: [indexPath], with: .top)
            StateController.instance.discard(article, for: .latest)
        }
    }
}
