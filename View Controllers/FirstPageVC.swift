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
    
    let refreshControl = UIRefreshControl()

    //MARK: Lifecycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        initViews()
        getPosts()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = true
    }

    //MARK: Class Methods
    func initViews() {
        lblTitle.text = "My Posts"
        btnAddPost.layer.cornerRadius = btnAddPost.frame.size.height/2
        
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        tvPosts.addSubview(refreshControl)
    }

    func deleteAction(post: Structs.Post, indexPath: IndexPath){
        self.tvPosts.beginUpdates()

        self.deletePost(id: post.id ?? "N/A")
        self.posts.remove(at: indexPath.row)
        self.tvPosts.deleteRows(at: [indexPath], with: .automatic)

        self.tvPosts.endUpdates()
    }
    
    @objc func refresh(_ sender: AnyObject) {
        getPosts()
    }
    
    //MARK: Buttons Actions
    @IBAction func btnAddPostAction(_ sender: Any) {
        CustomPopup.open(title: "Create a new post",
                         post: selectedPost,
                         delegate: self,
                         actionType: .create)
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
        
        cell.configureCell(post: post)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedPost = posts[indexPath.row]
        performSegueIfPossible(identifier: "firstPageVCToSecondPageVC")
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let postSelected = self.posts[indexPath.row]

        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            self.showActionSeetWithCompletion(title: "Delete Post",
                                         message: "You are about to delete this post. Are you sure you want to continue?") {
                self.deleteAction(post: postSelected, indexPath: indexPath)
            }
            completionHandler(true)
        }
        let editAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            if let isCreatedManually = postSelected.isCreatedManually, isCreatedManually {
                self.showAlert(message: Constants.Errors.EDIT_RESTRICTION_ERROR)
            }
            else{
                CustomPopup.open(title: "Edit post",
                                 post: postSelected,
                                 delegate: self,
                                 actionType: .edit)
            }
            completionHandler(true)
        }

        deleteAction.backgroundColor = UIColor(hexString: "#E34F4F")
        editAction.backgroundColor = UIColor(hexString: "#4CC679")

        if #available(iOS 13.0, *) {
            deleteAction.image = UIImage(named: "ic_clear")
            editAction.image = UIImage(named: "ic_edit")
        } else {
            // Fallback on earlier versions
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, editAction])
        
        return configuration
    }
    
}

//MARK: Requests Handler
extension FirstPageVC {
    func getPosts(){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts?userId=1"
        RequestManager.sharedManager.get(url: url, headers: nil, loading: true) { response in
            self.posts.removeAll()
            if let posts = response["data"] as? NSArray {
                for post in posts {
                    if let postDict = post as? NSDictionary {
                        self.parsePost(postDict: postDict, actionType: .none) { completed in
                            if completed {
                                //continue
                            }
                            else{
                                //Show Failure Alert
                            }
                        }
                    }
                }
            }
            self.hideProgressBar()
            self.refreshControl.endRefreshing()
            self.tvPosts.reloadData()
        } failure: { error in
            self.hideProgressBar()
            print(error)
        }

    }
    
    func deletePost(id:String){
        showProgressBar(message: "Loading Posts")
        
        let url = "\(Constants.urlPrefix)/posts/\(id)"
        let params: [String : AnyObject] = [:]
        
        RequestManager.sharedManager.delete(url: url, parameters: params, raw: false, loading: false) { response in
            self.hideProgressBar()
        } failure: { error in
            self.hideProgressBar()
            //Show Failure Alert
        }
    }
    
    func parsePost(postDict: NSDictionary, actionType:CustomPopupActionType, isCreatedManually:Bool = false, completion: (Bool) -> Void){
        
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
            
            if actionType == .edit {
                if let indexOfEditedElement = posts.firstIndex(where: { $0.id == "\(id)" }) {
//                    var postToEdit = posts[indexOfEditedElement]
                    posts[indexOfEditedElement].title = title
                    posts[indexOfEditedElement].body = body
                    tvPosts.reloadRows(at: [IndexPath(item: indexOfEditedElement, section: 0)], with: .fade)
                }
            }
            else{
                let post = Structs.Post(userId: userIdStr, id: "\(id)", title: title, body: body, isCreatedManually: isCreatedManually)
                posts.append(post)
            }
            completion(true)
        }
        else{
            completion(false)
        }
    }
}

// MARK: CustomPopup Delegate Methods
extension FirstPageVC:CustomPopupDelegate {
    func didPerformAction(post: NSDictionary?, actionType: CustomPopupActionType) {
        switch actionType {
        case .create:
            if let postDict = post {
                self.parsePost(postDict: postDict, actionType: actionType, isCreatedManually: true) { success in
                    if success {
                        tvPosts.reloadData()
                        tvPosts.scrollToBottom()
                    }
                    else{
                        //Show Failure Alert
                    }
                }
            }
            break
            
        case .edit:
            if let postDict = post {
                self.parsePost(postDict: postDict, actionType: actionType, isCreatedManually: true) { success in
                    if success {
                        tvPosts.reloadData()
                    }
                    else{
                        //Show Failure Alert
                    }
                }
            }
            break

        default:
            break
        }
    }
}
