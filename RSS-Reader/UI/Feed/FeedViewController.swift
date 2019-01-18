//
//  FeedViewController.swift
//  RSS-Reader
//
//  Created by  Oleksandra on 1/16/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

class FeedViewController: UITableViewController {

    let dataManager = DataManager()
    var feedArray = [Entry]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        feedArray = dataManager.parseXMLWithURL(URL(string:"https://www.wired.com/feed/rss")!)
        
        let nib = UINib(nibName: "FeedCell", bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: "FeedCell")
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        cell.titleLabel.text = entry.title
        cell.descriptionLabel.text = entry.description
        cell.categoryLabel.text = entry.category
        cell.creatorLabel.text = entry.creator
        cell.publisherLabel.text = entry.publisher
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"//
        let formattedDate = formatter.date(from: formatter.string(from: entry.pubDate!))
        formatter.dateFormat = "MMM d, h:mm a"
        cell.dateLabel.text = formatter.string(from: formattedDate!)
        
        let dataTask = URLSession.shared.dataTask(with: entry.imageURL!) { (data, response, error) in
            if error != nil {
                print(error!)
                return
            }
            DispatchQueue.global(qos:.userInitiated).async {
                let image = UIImage(data:data! as Data)
                DispatchQueue.main.async {
                    cell.entryImageView?.image = image
                    cell.activityIndicator.stopAnimating()
                }
            }
        }
        dataTask.resume()
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "ShowEntryDetails", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowEntryDetails" {
            let vc: EntryViewController = segue.destination as! EntryViewController
            vc.link = feedArray[tableView.indexPathForSelectedRow!.row].link
        }
    }
    
}

