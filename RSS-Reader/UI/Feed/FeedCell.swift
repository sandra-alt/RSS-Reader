//
//  FeedCell.swift
//  RSS-Reader
//
//  Created by  Oleksandra on 1/16/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit

class FeedCell: UITableViewCell {

    @IBOutlet weak var entryImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var creatorLabel: UILabel!
    @IBOutlet weak var publisherLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func setupCellForEntry(entry: Entry) {
        titleLabel.text = entry.title
        descriptionLabel.text = entry.description
        categoryLabel.text = entry.category
        creatorLabel.text = entry.creator
        publisherLabel.text = entry.publisher
        
        let formattedDate = dateFormatter.date(from: dateFormatter.string(from: entry.pubDate!))
        dateLabel.text = shortDateFormatter.string(from: formattedDate!)

        imageURL = entry.imageURL!
        setupEntryImageForURL(url: imageURL)

    }
    
    //MARK: - Image loading
    
    fileprivate var imageURL: URL?
    
    fileprivate func setupEntryImageForURL(url: URL?) {
        entryImageView?.image = nil
        activityIndicator.startAnimating()
        
        if let imageFromCache = imageCache.object(forKey: url as AnyObject){
            entryImageView?.image = imageFromCache
            activityIndicator.stopAnimating()
            return
        } else {
            loadImage(withURL: url) { (image) in
                self.entryImageView?.image = image
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    fileprivate let imageCache = NSCache<AnyObject, UIImage>()
    fileprivate func loadImage(withURL url: URL?, completionHandler: @escaping(UIImage?) -> Void) {
        
        URLSession.shared.dataTask(with: url!) { (data, response, error) in
            guard let data = data else {
                print("Can't load an image")
                return
            }
            DispatchQueue.main.async {
                let imageToCache = UIImage(data:data)
                self.imageCache.setObject(imageToCache!, forKey: url as AnyObject)
                if self.imageURL == url {
                    completionHandler(imageToCache)
                }
            }
        }.resume()
    }
    
    //MARK: - DateFormatters
    
    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        
        return df
    }
    
    private var shortDateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateFormat = "MMM d, h:mm a"
        
        return df
    }
}
