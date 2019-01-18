//
//  EntryViewController.swift
//  RSS-Reader
//
//  Created by  Oleksandra on 1/17/19.
//  Copyright © 2019 sandra-alt. All rights reserved.
//

import UIKit
import WebKit

class EntryViewController: UIViewController {

    var link: URL?
    
    @IBOutlet weak var entryWebView: WKWebView!
    override func viewDidLoad() {
        super.viewDidLoad()
        entryWebView.load(URLRequest(url: link!))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
