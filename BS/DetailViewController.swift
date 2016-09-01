//
//  DetailViewController.swift
//  BS
//
//  Created by daniel martinez gonzalez on 19/8/16.
//  Copyright © 2016 daniel martinez gonzalez. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

class DetailViewController: UIViewController
{
    
    var urlPost : String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        let buttonL: UIButton = UIButton()
        buttonL.setImage(UIImage(named: "bt_back.png"), forState: .Normal)
        buttonL.frame = CGRectMake(0, 0, 30, 30)
        buttonL.addTarget(self, action: #selector(DetailViewController.Back_Press(_:)), forControlEvents: .TouchUpInside)
        
        let leftItem:UIBarButtonItem = UIBarButtonItem()
        leftItem.customView = buttonL
        self.navigationItem.leftBarButtonItem = leftItem
        
        
        let url = NSURL (string: urlPost!)
        let requestObj = NSURLRequest(URL: url!)
        self.webView.loadRequest(requestObj);
    }
    
    func Back_Press(sender: UIButton!)
    {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}
