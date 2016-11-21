//
//  LatestFeedTableViewController.swift
//  News
//
//  Created by James Wilkinson on 21/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class LatestFeedTableViewController: UITableViewController {
    
    fileprivate var data: [Article] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        self.tableView.register(UINib(nibName: "ArticleTableViewCell", bundle: nil), forCellReuseIdentifier: "article")
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 140
        
        StateController.instance.subscribe(to: .latest) {
            switch $0 {
            case .preloaded(let articles):
                self.data = articles
                self.reloadData()
            case .error(_):
                self.data = []
                self.reloadData()
            case .downloading:
                break
            case .loaded(let articles):
                self.data = articles
                self.reloadData()
            }
        }
        StateController.instance.downloadFeedArticles()
    }
    
    private func reloadData() {
        DispatchQueue.main.async {
            self.tableView.reloadSections([0], with: .automatic)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return data.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "article", for: indexPath) as! ArticleTableViewCell
        
        cell.headline.text = data[indexPath.row].title
        cell.source.text = data[indexPath.row].source
        
        cell.delegate = self
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LatestFeedTableViewController: ArticleTableViewCellDelegate {
    func articleCell(_ cell: ArticleTableViewCell, didCommit action: ArticleTableViewCell.Action) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        
        switch action {
        case .readLater:
            // TODO: Implement saved articles
            // TODO: save this article
            self.tableView.reloadRows(at: [indexPath], with: .right)
            
        case .discard:
            data.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .top)
            StateController.instance.set(self.data, for: .latest)
        }
    }
}
