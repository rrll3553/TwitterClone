//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Henry M on 10/10/21.
//  Copyright © 2021 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArray = [NSDictionary]()
    var numberOfTweet: Int!
    
    // to handle pull to refresh
    let myRefreshControl = UIRefreshControl()
    
    
    // when screen is done loading for the first time
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets() // run loadtweets when screen is finished loading
        
        // to handle pull to refresh
        // want target to be self - this own screen
        // use # selector to pick function to redo. fix will auto add @obj function to the load tweet function
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func loadTweets() {
        // will always be 20 from when you first start or pull to refresh
        numberOfTweet = 20
        
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let myParams = ["count": numberOfTweet]
        
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            // reloads the data every time it makes a call to the API
            self.tableView.reloadData()
            
            // will end the refreshing icon (necessary or else loading refresh stays)
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })
    }
    
    // will handle the continuous scrolling
    func loadMoreTweets(){
        let myUrl = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        numberOfTweet = numberOfTweet + 20
        let myParams = ["count": numberOfTweet]
        TwitterAPICaller.client?.getDictionariesRequest(url: myUrl, parameters: myParams as [String : Any], success: { (tweets: [NSDictionary]) in
            self.tweetArray.removeAll()
            for tweet in tweets {
                self.tweetArray.append(tweet)
            }
            
            // reloads the data every time it makes a call to the API
            self.tableView.reloadData()
            
            // will end the refreshing icon (necessary or else loading refresh stays)
            self.myRefreshControl.endRefreshing()
            
        }, failure: { (Error) in
            print("Could not retrieve tweets!")
        })

    }
    
    // for when a user gets to end of the screen, call load more tweets
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArray.count {
            loadMoreTweets()
        }
    }
    
    
    
    
    
    
    

    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        // to get rid of the persistent storage after they've logged out
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        // need to add the as! tweetcelltableviewcell to allow access to userNameLabel, tweetContent, and profileImageView
        
        let user = tweetArray[indexPath.row]["user"] as! NSDictionary
        
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetContent.text = tweetArray[indexPath.row]["text"] as? String
        // indexPath iterates through the tweetArray for you
        
        let imageUrl = URL(string: (user["profile_image_url_https"] as? String)!)
        let data = try? Data(contentsOf: imageUrl!)
        
        if let imageData = data { cell.profileImageView.image = UIImage(data: imageData)
            
        }
        
        
        return cell
    }
    // MARK: - Table view data source
    // how many sections you want
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    // how many rows per section you want
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArray.count
    }

}
