//
//  FeedViewController.swift
//  RSS-Reader
//
//  Created by  Oleksandra on 1/16/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController {
    
    let urlString = "https://www.wired.com/feed/rss"
    
    let dataManager = DataManager()
    var feedArray = [Entry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        refresh()
        
        let feedCellName = "FeedCell"
        let nib = UINib(nibName: feedCellName, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: feedCellName)

        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView.addSubview(refreshControl!)
    }
    
    // MARK: - Refreshing displayed feed
    
    @objc func refresh() {
        requestUpdate()
    }

    private func requestUpdate() {
        DispatchQueue.global(qos:.userInitiated).async {
            let newItems = self.dataManager.parseXMLWithURL(URL(string:self.urlString)!)
            
            DispatchQueue.main.async {
                defer {
                    self.refreshControl?.endRefreshing()
                }
                
                if newItems.isEmpty {
                    let alertController = UIAlertController(title: "Error", message: "The feed is failed to load", preferredStyle: .alert)
                    alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertController, animated: true, completion:{})
                    return
                }
                
                self.feedArray = newItems
                self.tableView.reloadData()
            }
        }
        
    }

    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return feedArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedCell", for: indexPath) as! FeedCell
        
        let entry = feedArray[indexPath.row]
        cell.setupCellForEntry(entry: entry)
        
        return cell
    }
    
    //MARK: - Segues
    
    private let showEntrySegue = "ShowEntryDetails"
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: showEntrySegue, sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == showEntrySegue {
            let vc: EntryViewController = segue.destination as! EntryViewController
            vc.link = feedArray[tableView.indexPathForSelectedRow!.row].link
        }
    }
    
}

