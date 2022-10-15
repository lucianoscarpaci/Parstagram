//
//  FeedViewController.swift
//  Parstagram-app
//
//  Created by luciano scarpaci on 9/28/22.
//

import UIKit
import Parse
import AlamofireImage
import MessageInputBar

class FeedViewController: UIViewController, UITableViewDelegate,
                          UITableViewDataSource, MessageInputBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    // create empty array object of PFObject
    let commentBarView = MessageInputBar()
    var commentBarEnabled = false
    var posts = [PFObject]()
    
    @IBAction func OnLogoutButton(_ sender: Any) {
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "LoginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene, let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        delegate.window?.rootViewController = loginViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        commentBarView.inputTextView.placeholder = "Add a comment..."
        commentBarView.sendButton.title = "Post"
        commentBarView.delegate = self

        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.keyboardDismissMode = .interactive
        
        let NScenter = NotificationCenter.default
        NScenter.addObserver(self, selector: #selector(keyboardAppearHidden(note:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    @objc func keyboardAppearHidden(note: Notification) {
        commentBarView.inputTextView.text = nil
        commentBarEnabled = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBarView
    }
    
    override var canBecomeFirstResponder: Bool {
        return commentBarEnabled
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make the query
        let query = PFQuery(className:"Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment
        
        //clear and dismiss
        commentBarView.inputTextView.text = nil
        
        
        commentBarEnabled = false
        becomeFirstResponder()
        commentBarView.inputTextView.resignFirstResponder()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) ->
    Int {
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        return comments.count + 2 //one photo for every post
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) ->
        UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.usernameLabel.text = user.username
            
            cell.commentLabel.text = post["caption"] as? String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let myURL = URL(string: urlString)!
            
            cell.posterView.af.setImage(withURL: myURL)
            
            return cell
        } else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentCell") as! CommentCell
            
            //code is working at this point
            let newComment = comments[indexPath.row - 1]
            cell.nameLabel.text = newComment["text"] as? String
            
            let newUser = newComment["author"] as! PFUser
            cell.nameLabel.text = newUser.username
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let post = posts[indexPath.section]
        
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == comments.count + 1 {
            commentBarEnabled = true
            becomeFirstResponder()
            commentBarView.inputTextView.becomeFirstResponder()
            
        }
        /* comment["text"] = "This is a random comment"
        comment["post"] = post
        comment["author"] = PFUser.current()!
        
        post.add(comment, forKey: "Comments")
        
        post.saveInBackground { (success, error) in
            if success {
                print("comment saved")
            }
            else {
                print("error saving comment")
            }
        }*/
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
