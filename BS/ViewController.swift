//
//  ViewController.swift
//  BS
//
//  Created by daniel martinez gonzalez on 19/8/16.
//  Copyright © 2016 daniel martinez gonzalez. All rights reserved.
//

import UIKit
import RealmSwift

class ViewController: UIViewController , UICollectionViewDataSource, UICollectionViewDelegate
{

    var Load : Bool = false
    var sortCase : Int = 0

    var refreshControl:UIRefreshControl!
    
    @IBOutlet weak var ViewLoad: UIView!
    @IBOutlet weak var CollectionView: UICollectionView!
    @IBOutlet weak var Segment: UISegmentedControl!
    
    
    @IBAction func Sort(sender: AnyObject)
    {
        
        dispatch_async(dispatch_get_main_queue())
        {
        switch self.Segment.selectedSegmentIndex
        {
        case 0:
            self.sortCase = 1
            self.CollectionView.reloadData()
            break
            
        case 1:
            self.sortCase = 2
            self.CollectionView.reloadData()
            break
            
        case 2:
            self.sortCase = 3
            self.CollectionView.reloadData()
            break
            
        default:
            break
        }
        }
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.refreshControl = UIRefreshControl()
        self.refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        self.refreshControl.addTarget(self, action: #selector(ViewController.refresh(_:)),   forControlEvents: UIControlEvents.ValueChanged)
        
        self.CollectionView.addSubview(refreshControl)
        
        
        let realm = try! Realm()
        let post = realm.objects(Post.self)
        
        if post.count > 0
        {
            self.ShowData()
        }
        else
        {
            self.DownLoadData()
        }

    }
    
    func refresh(sender:AnyObject)
    {
        //DO
        self.DownLoadData()
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func DownLoadData ()
    {
        // Simple NSURL API CALL
        
        let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        
        let request = NSURLRequest(URL: NSURL(string: "https://api.reddit.com/r/programming/new.json")!)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            if let data = data
            {
                
                var result:AnyObject
                
                do
                {
                    //let realm = try! Realm()
                    
                    result = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions()) as! NSDictionary
                    
                    let ArrPost : NSArray = (result["data"] as! NSDictionary).objectForKey("children") as! NSArray
                    
                    for i in 0  ..< ArrPost.count 
                    {
                        let DictPost : NSDictionary = (ArrPost.objectAtIndex(i) as! NSDictionary).objectForKey("data") as! NSDictionary
                        self.SavePost(DictPost)
                    }
                    if !self.Load
                    {
                        self.ShowData()
                    }
                    else
                    {
                        dispatch_async(dispatch_get_main_queue())
                        {
                            self.refreshControl.endRefreshing()
                            self.CollectionView.reloadData()
                        }
                    }
                }
                catch
                {
                    print("ERROR API CALL")
                }
            }
        }
        task.resume()
    }
    
    func ShowData()
    {
        dispatch_async(dispatch_get_main_queue())
        {
            self.Load = true
            self.ViewLoad.hidden = true
            self.CollectionView.reloadData()
        }

    }
    
    func SavePost(dict : NSDictionary)
    {
        
        var id : String = ""
        var author : String = ""
        var title : String = ""
        var created : Double = 0.0
        var DateCreated : String = "1 days ago"
        var score : Int = 0
        var comments : Int = 0
        var thumbnail : String = ""
        var url : String = ""
        
        if dict["id"] != nil
        {
            id = dict["id"] as! String
        }
        
        if dict["author"] != nil
        {
            author = dict["author"] as! String
        }
        
        if dict["title"] != nil
        {
            title = dict["title"] as! String
        }
        
        if dict["created"] != nil
        {
            created = dict["created"] as! Double
            created = (created / 86400)
            
            DateCreated = String(Int(created)) + " days ago"
        }
        
        if dict["score"] != nil
        {
            score = dict["score"] as! Int
        }

        if dict["num_comments"] != nil
        {
            comments = dict["num_comments"] as! Int
        }
        
        if dict["thumbnail"] != nil
        {
            thumbnail = dict["thumbnail"] as! String
        }
        
        if dict["url"] != nil
        {
            url = dict["url"] as! String
        }
        

        let realm = try! Realm()
        
        let post = Post()
        post.id = id
        post.author = author
        post.title = title
        post.created = DateCreated
        post.score = score
        post.comments = comments
        post.thumbnail = thumbnail
        post.url = url
        
        try! realm.write
        {
                realm.add(post , update: true)
        }
        
    }
    
    
    // MARK: - UICollectionViewDataSource protocol
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        if !Load
        {
            return 0
        }
        else
        {
            let realm = try! Realm()
            let post = realm.objects(Post.self)
            
            switch sortCase
            {
            case 0:
                return post.count
                
            case 1:
                let hotPost = realm.objects(Post.self).sorted("score", ascending: false)
                return hotPost.count
                
            case 2:
                let CommentPost = realm.objects(Post.self).sorted("comments", ascending: false)
                return CommentPost.count
             
            case 3:
                let NewPost = realm.objects(Post.self).sorted("created", ascending: true)
                return NewPost.count
                
            default:
                return post.count
            }
        }
    }
    
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CCell", forIndexPath: indexPath) as! CollectionCell
        
        let realm = try! Realm()
        var post = realm.objects(Post.self)
        
        switch sortCase
        {
        case 0:
            break;
            
        case 1:
            post = realm.objects(Post.self).sorted("score", ascending: false)
            break;
            
        case 2:
            post = realm.objects(Post.self).sorted("comments", ascending: false)
            break;
            
        case 3:
            post = realm.objects(Post.self).sorted("created", ascending: true)
            break;
            
        default:
            break;
        }
        
        cell.AuthorLabel.text = post[indexPath.row].author
        cell.TitleLabel.text = post[indexPath.row].title
        cell.DateLabel.text = post[indexPath.row].created
        cell.ScoreLabel.text = String ( (post[indexPath.row].score)) + " score"
        cell.CommentsLabel.text = String ( (post[indexPath.row].comments)) + " comments"
        //cell.IMG.image =
        
        cell.backgroundColor = UIColor.whiteColor()
        cell.layer.borderColor = UIColor.grayColor().CGColor
        cell.layer.borderWidth = 1
        cell.layer.cornerRadius = 6
        
        return cell
    }
    
    // MARK: - UICollectionViewDelegate protocol
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        let realm = try! Realm()
        let post = realm.objects(Post.self)
        
        let DetailV = self.storyboard?.instantiateViewControllerWithIdentifier("DetailView") as? DetailViewController
        
        DetailV?.urlPost = post[indexPath.row].url
        
        self.navigationController?.pushViewController(DetailV!, animated: true)
        
    }
    
    
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.lightGrayColor()
    }
    
    // change background color back when user releases touch
    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath)
    {
        let cell = collectionView.cellForItemAtIndexPath(indexPath)
        cell?.backgroundColor = UIColor.whiteColor()
    }
    
    
    // MARK: - Sort 
    
    
    
}


