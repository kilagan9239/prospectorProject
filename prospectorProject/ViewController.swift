//  ViewController.swift
//  prospectorProject
//  Created by period3 on 10/26/18.

//  Copyright © 2018 period3. All rights reserved.
//
import UIKit
import NotificationCenter
import OneSignal

var articleInfo: ArticleInfo!

//hey guys! henning and I were thinking that we could clear the table view before storing articles? We may be able to do so in the function that stores the articles in the table view cell by clearing the table view and then adding in the articles so we can avoid repeating articles in a table view once a button is clicked on again. -Helen 

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate {
    
    //Parse Things (Helen's Code + Kai's Copy For Search Button)
    var articles = [[String: String]]()
    var categories1 = [String]()
    var descriptions1 = [String]()
    var dates1 = [String]()
    var searchBool = false
    var contentString1: String!
    var numberOfCategories = [Int]()
    var articlesStruct = [Article]()
    var filteredArticlesStruct = [Article]()
    let searchController = UISearchController(searchResultsController: nil)
    var pathway: String!
    var imageArticles = [[String: UIImage]]()
    var imagePicker = UIImagePickerController()
    var fileURL: URL!
    var thumbnail: UIImage!
    var images = [ImageData]() {
        didSet {
            writeToFile()
        }
    }

    var oneSignal = OneSignal()

    //Side Menu + Loading Stuff
    
    @IBOutlet weak var leadingC: NSLayoutConstraint!
    @IBOutlet weak var trailingC: NSLayoutConstraint!
    @IBOutlet weak var primeView: UIView!
    
    var hamburgerIsVisible = false;
    
    // Article stuff for Parse (May Or May Not Be Working)
    
    var articleArray = [ArticleInfo]()
    
    // Collection View
    
    @IBOutlet weak var mainCollectionView: UICollectionView!
    
    // Side Menu
    
    override func viewWillAppear(_ animated: Bool){
       mainCollectionView.reloadData()
    }
    
    // ViewDidLoad
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        print(OneSignal.app_id())
        
        print(articlesStruct.count)
        // Setup the Search Controller
        searchController.searchResultsUpdater = self as! UISearchResultsUpdating
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Articles"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        mainCollectionView.backgroundColor = UIColor.viewProspectBlue
        mainCollectionView.reloadData()
        let homePageQuery = "https://api.rss2json.com/v1/api.json?rss_url=https%3A%2F%2Fprospectornow.com%2F%3Ffeed%3Drss2"
        
        var link = "http://motyar.info/webscrapemaster/api/?url=https://prospectornow.com/?p=\(pathway)&xpath=//div[@id=cb-featured-image]/div[1]/img#vws"
        
//        DispatchQueue.global(qos: .userInitiated).async {
//            [unowned self] in
//            if let url = URL(string: link)
//            {
//                if let data = try? Data(contentsOf: url)
//                {
//                    let json2 = try! JSON(data: data)
//                    self.parse(json: json2)
//                    return
//
//                }
//            }
//            self.loadError()
//        }
            DispatchQueue.global(qos: .userInitiated).async {
                [unowned self] in
                if let url = URL(string: homePageQuery)
                {
                    if let data = try? Data(contentsOf: url)
                    {
                        let json = try! JSON(data: data)
                        if json["status"] == "ok"
                        {
                            self.parse(json: json)
                            return
                        }
                    }
            }
            self.loadError()
        }
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsURL = paths[0]
        fileURL = documentsURL.appendingPathComponent("Image")
        readFromFile()
        
        imagePicker.delegate = self
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        imagePicker.dismiss(animated: true)
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            self.images.append(ImageData(image: UIImagePNGRepresentation(selectedImage)!, like: false, text: ""))
            mainCollectionView.reloadData()
        }
    }
    
    func readFromFile() {
        do {
            let data = try Data(contentsOf: fileURL)
            let images = try PropertyListDecoder().decode([ImageData].self, from: data)
            self.images = images
            print("Successful readFromFile")
        }
        catch {
            print("Failed readFromFile")
        }
    }
    
    func writeToFile() {
        do {
            let data = try PropertyListEncoder().encode(images)
            try data.write(to: fileURL!)
            print("Succeddsul writeToFile")
        }
        catch {
            print("Failed writeToFile")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        searchBool = true
    }
    
    //MARK: Side Menu
    @IBAction func hamburgerButton(_ sender: UIBarButtonItem) {
        if !hamburgerIsVisible
        {
            leadingC.constant = 129
            trailingC.constant = 0
            
            searchController.searchBar.isHidden = true
                        
            hamburgerIsVisible = true
        }
        else
        {
            leadingC.constant = 0
            trailingC.constant = 0
            
            searchController.searchBar.isHidden = false
            hamburgerIsVisible = false
        }
        
        UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseInOut, animations: {
            self.view.layoutIfNeeded()
        }) { (animationComplete) in
            print("The animation is complete!")
        }
        mainCollectionView.reloadData()
    }
    
    
    //MARK: Parse Function
    func parse(json: JSON)
    {
        for result in json["items"].arrayValue
        {
            let title = result["title"].stringValue
            let pubDate = result["pubDate"].stringValue
            let description = result["description"].stringValue
            let content = result["content"].stringValue
            let articleThumbnail = result["thumbnail"].stringValue
            let category = result["categories"].arrayValue
            let categories = String(result["categories"].arrayValue.count)
            let link = result["link"].stringValue

            articlesStruct.append(Article(title: title, pubDate: pubDate, description: description, content: content, categories: categories, link: link))

            let source = ["title":title, "pubDate":pubDate, "description": description, "content":content, "articleThumbnail": articleThumbnail, "categories": categories, "link": link]
            
            articles.append(source)
            //images.append(articleThumbnail)
            contentString1 = content
            print("We're parsing babey")
            
            let count = category.count - 1
            
            for i in 0...count
            {
                categories1.append(category[i].stringValue)
            }
            
            
            // I FIXED IT
            descriptions1.append(title)
            dates1.append(pubDate)
            
        }

        if searchBool == true
        {
        DispatchQueue.main.async {
        
        self.mainCollectionView.reloadData()
            }
        }
    }
    //MARK: - Parse Image
//    func parseImage(json2: JSON)
//    {
//        getPathway(link: "https://prospectornow.com/?p=20691")
//
//        for result in json2[""].arrayValue
//        {
//            let imageString = result["src"].stringValue
//
//            let url = URL(string: imageString)
//            if let data = try? Data(contentsOf: url!)
//            {
//                let image: UIImage = UIImage(data: data)!
//                thumbnail = image
//            }
//            var source = ["src": thumbnail]
//            imageArticles.append(source as! [String : UIImage])
//
//            //  let source = ["title":title, "pubDate":pubDate, "description": description, "content":content, "articleThumbnail": articleThumbnail, "categories": categories]
//
//            print("double parse babey")
//
//
//        }
//    }
    
    //MARK: - Load Error
    func loadError() {
        
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Loading Error", message: "There was a problem loading the news feed", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            
            self.present(alert, animated: true, completion: nil)
            
        }
        
    }
    
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?)
//    {
//        let vc = segue.destination as! ArticleViewController
//        vc.articleSource = articles
//        vc.contentString = contentString1
//
//    }
    
//******Start of Helen's Code (Also please see top of Viewcontroller)***************************************************
    var arrayHolder = [[String:String]]()
    
    //MARK: Trending

    @IBAction func trendingButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Trending"
                {
                    arrayHolder.append(one)
                    print(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
    //MARK: Sports
    
    var sportsArrayHolder = [[String: String]]()

    @IBAction func sportsButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Sports"
                {
                    sportsArrayHolder.append(one)
                    print(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
    //MARK: Entertainment
    
    var entertainmentArrayHolder = [[String: String]]()

    @IBAction func entertainmentButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Entertainment"
                {
                    entertainmentArrayHolder.append(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
    //MARK: News
    
    var newsArrayHolder = [[String: String]]()

    @IBAction func newsButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "News"
                {
                    arrayHolder.append(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
    }
    
    //MARK: Features
    
    var featuresArrayHolder = [[String: String]]()

    @IBAction func featuresButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Features"
                {
                    featuresArrayHolder.append(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
    //MARK: Opinion
    
    var opinionArrayHolder = [[String: String]]()

    @IBAction func opinionButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Opinion"
                {
                    opinionArrayHolder.append(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
    //MARK: Other
    var otherArrayHolder = [[String: String]]()
    var realOtherArray = [[String: String]]()
    @IBAction func otherButton(_ sender: UIButton)
    {
        var holderC = [String]()
        var count = articles.count - 1
        
        for k in 0...(categories1.count - 1)
        {
            holderC.append(categories1[k])
        }
        
        for i in 0...count
        {
            var one = articles[i]
            var cValue = one["categories"]
            var cCount = Int(cValue!)! - 1
            for j in 0...cCount
            {
                if holderC[j] == "Other"
                {
                    otherArrayHolder.append(one)
                }
            }
            for k in 0...cCount
            {
                holderC.remove(at: 0)
            }
        }
        
    }
    
  
    
    // MARK: - Private instance methods
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty or nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All") {
        filteredArticlesStruct = articlesStruct.filter({( article : Article) -> Bool in
            return article.title.lowercased().contains(searchText.lowercased())
        })
        
        mainCollectionView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }


    //MARK: Start of Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
        //NEWS SEGUE
        if segue.identifier == "newsSegue"
        {
            let nvc = segue.destination as! NewsViewController
            var count1 = arrayHolder.count - 1
            
            if count1 > -1
            {
                for k in 0...count1
                {
                    nvc.arrayofArticlesNews.append(arrayHolder[k])
                }
            }
        } //the segue between the main view controller and the second view controller for news. In the second view controller, SpecificTypeofArticle view controller for news, an empty dictonary exists. All these segues store the articles assigned in a holder array from the button functions above into these dictonaries. They consist of the articles that are catorgized for each category. Ex: SpecificTypeofArticleViewController has an array called arrayofArticlesNews that all the articles that are "News" are stored in.
        
        else if segue.identifier == "opinionSegue"
        {
            let nvc = segue.destination as! OpinionViewController
            var count1 = opinionArrayHolder.count - 1
            
            if count1 > -1
            {
                for k in 0...count1
                {
                    nvc.arrayofArticlesOpinions.append(opinionArrayHolder[k])
                }
            }
        }
          
            
        else if segue.identifier == "entertainmentSegue"
        {
            let nvc = segue.destination as! EntertainmentViewController
            var count1 = entertainmentArrayHolder.count - 1
            
            if count1 > -1
            {
                for k in 0...count1
                {
                    nvc.arrayofArticlesEntertainment.append(entertainmentArrayHolder[k])
                }
            }
        }
            
        else if segue.identifier == "otherSegue"
        {
            let nvc = segue.destination as! OtherViewController
            var count1 = otherArrayHolder.count - 1
            var counter = 0
            if count1 > 0
            {
            for h in 0...count1
            {
                var tester = otherArrayHolder[h]
                
                for mo in 0...count1
                {
                    if tester == otherArrayHolder[mo]{
                        counter = counter + 1                    }
                }
                
                if counter <= 1 {
                    realOtherArray.append(tester)
                    print(realOtherArray.count)
                }
                counter = 0
            }
            }
            var count2 = realOtherArray.count - 1
            
            if count2 > -1
            {
                for k in 0...count2
                {
                    nvc.arrayofArticlesOther.append(realOtherArray[k])
                    
                }
            }
        }
        else if segue.identifier == "featuresSegue"
        {
            let nvc = segue.destination as! FeaturesViewController
            var count1 = featuresArrayHolder.count - 1
            
            if count1 > -1
            {
                for k in 0...count1
                {
                    nvc.arrayofArticlesFeatures.append(featuresArrayHolder[k])
                }
            }
        }
        else if segue.identifier == "sportsSegue"
        {
            let nvc = segue.destination as! SportsViewController
            var count1 = sportsArrayHolder.count - 1
            
            if count1 > -1
            {
                for k in 0...count1
                {
                    nvc.arrayofArticlesSports.append(sportsArrayHolder[k])
                }
            }
        }
        else if segue.identifier == "specificSegue"
        {
            let nvc = segue.destination as! SpecificArticleViewController
            nvc.specificArticle = articles
            nvc.content0 = contentString1
            let cell = sender as! UICollectionViewCell
            if let indexPath = self.mainCollectionView.indexPath(for: cell) {
                let article: Article
                if isFiltering() {
                    article = filteredArticlesStruct[indexPath.row]
                } else {
                    article = articlesStruct[indexPath.row]
                }
                nvc.specificArticleStruct = article
            }
        }
        //MARK: End of Prepare for Segues
}
}
extension ViewController: UISearchResultsUpdating {
    // MARK: - UISearchResultsUpdating Delegate
    func updateSearchResults(for searchController: UISearchController) {
        // TODO
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

//MARK: Collection View
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ mainCollectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(articlesStruct.count)
        return articlesStruct.count
    }
    
    func collectionView(_ mainCollectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //WHY IS THIS A BITCH?
        let cell = mainCollectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? CollectionViewCell
        let article: Article
        article = articlesStruct[indexPath.row]
        cell?.articleLabel.text = article.title
        print(cell?.articleLabel.text)
        cell?.articleLabel.backgroundColor = UIColor.prospectBlue
        cell?.articleDateLabel.text = article.pubDate
        print(cell?.articleDateLabel.text)
        cell?.articleDateLabel.backgroundColor = UIColor.darkerProspectBlue
        return cell!
    }
}

extension String {
    subscript(i: Int) -> String {
        return String(self[index(startIndex, offsetBy: i)])
    }
}

