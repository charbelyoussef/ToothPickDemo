//
//  FirstPageVC.swift
//  ToothpickDemo (iOS)
//
//  Created by Youssef on 7/14/21.
//

import UIKit

class FirstPageVC: UIViewController {
    
    //MARK: Outlets
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var tvPosts: UITableView!
    @IBOutlet weak var btnAddPost: UIButton!
    
    //MARK: Class Variables
    var posts = [Structs.Post]()
    var rowHeight:CGFloat = 100
    
    var postToDelete:Structs.Post?
    var selectedPost:Structs.Post?
    
    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        getPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        initViews()
    }
    
    //MARK: Class Methods
    func initViews() {
        lblTitle.text = "My Posts"
        btnAddPost.layer.cornerRadius = btnAddPost.frame.size.height/2
    }
    
    
    func delete(post: Structs.Post, indexPath: IndexPath) {
        let alert = UIAlertController(title: "Delete Post", message: "You are about to delete this post. Are you sure you want to continue?", preferredStyle: .actionSheet)

        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { action in
            self.tvPosts.beginUpdates()

            self.deletePost(id: post.id ?? "N/A")
            self.posts.remove(at: indexPath.row)
            self.tvPosts.deleteRows(at: [indexPath], with: .automatic)

            self.tvPosts.endUpdates()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)

        alert.popoverPresentationController?.sourceView = self.view
//        alert.popoverPresentationController?.sourceRect = CGRect(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.0, 1.0, 1.0)

        self.present(alert, animated: true, completion: nil)
    }

    //MARK: Buttons Actions
    @IBAction func btnAddPostAction(_ sender: Any) {
        createPost(title: "title1", body: "Bodzyyyy", userId: 1)
    }
    
    //MARK: Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "firstPageVCToSecondPageVC" {
            if let vc = segue.destination as? SecondPageVC {
                vc.post = selectedPost
            }
        }
    }

}

//MARK: UITableView Methods
extension FirstPageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstPageVCContentCell") as! FirstPageVCContentCell
        let post = posts[indexPath.row]
        
        cell.lblTitle.text = post.title
        cell.lblBody.text = post.body

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegueIfPossible(identifier: "firstPageVCToSecondPageVC")
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let postToDelete = posts[indexPath.row]
            delete(post: postToDelete, indexPath: indexPath)
        }
    }
    
}

//MARK: Requests Handler
extension FirstPageVC {
    func getPosts(){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts?userId=1"
        RequestManager.sharedManager.get(url: url, headers: nil, loading: true) { response in
            if let posts = response["data"] as? NSArray {
                for post in posts {
                    if let postDict = post as? NSDictionary {
                        self.parsePost(postDict: postDict) { completed in
                            if completed {
                                //continue
                            }
                            else{
                                //showError
                            }
                        }
                    }
                }
            }
            self.hideProgressBar()
            self.tvPosts.reloadData()
        } failure: { error in
            self.hideProgressBar()
            print(error)
        }

    }
    
    func createPost(title:String, body:String, userId:Int){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts"
        
        var params: [String : AnyObject] = [:]
        params["title"] = title as AnyObject
        params["body"] = body as AnyObject
        params["userId"] = userId as AnyObject

        RequestManager.sharedManager.post(url: url, parameters: params, headers: nil, raw: false, loading: false) { response in
            self.hideProgressBar()

            self.parsePost(postDict: response, isCreatedManually: true) { completed in
                if completed {
                    self.tvPosts.reloadData()
                }
                else{
                    //ShowError
                }
            }
            
            
        } failure: { error in
            self.hideProgressBar()
            //ShowAlert
        }
    }
    
    func editPost(id:String, title:String, body:String, userId:Int){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts/\(id)"
        
        var params: [String : AnyObject] = [:]
        params["title"] = title as AnyObject
        params["body"] = body as AnyObject
        params["userId"] = userId as AnyObject

        
        RequestManager.sharedManager.put(url: url, parameters: params, raw: false, loading: false) { response in
            self.hideProgressBar()

            self.parsePost(postDict: response) { completed in
                if completed {
                    self.tvPosts.reloadData()
                }
                else{
                    //ShowError
                }
            }
        } failure: { error in
            self.hideProgressBar()
            //ShowAlert
        }
    }
    
    func deletePost(id:String){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts/\(id)"

        let params: [String : AnyObject] = [:]

        RequestManager.sharedManager.delete(url: url, parameters: params, raw: false, loading: false) { response in
            self.hideProgressBar()

//            if let postEdited = response as? NSDictionary {
                //ShowAlert "Deleted"
//            }
        } failure: { error in
            self.hideProgressBar()
            //ShowAlert
        }
    }
    
    func parsePost(postDict: NSDictionary, isCreatedManually:Bool = false, completion: (Bool) -> Void){
        if let id = postDict["id"] as? Int,
            let title = postDict["title"] as? String,
            let body = postDict["body"] as? String {
            
            var userIdStr = ""
            if let userId = postDict["userId"] as? Int {
                userIdStr = "\(userId)"
            }
            if let userIdTemp = postDict["userId"] as? String {
                userIdStr = userIdTemp
            }

            let post = Structs.Post(userId: userIdStr, id: "\(id)", title: title, body: body, isCreatedManually: isCreatedManually)
            posts.append(post)
            completion(true)
        }
        else{
            completion(false)
        }
    }
}
