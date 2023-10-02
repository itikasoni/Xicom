//
//  ImageListingVC.swift
//  Xicom M Test
//
//  Created by Itika Soni on 13/09/23.
//

import UIKit

class ImageListingVC: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var imgListArr = [Image]()
    var cellHeightCache = [IndexPath: CGFloat]()
    var pageNo = 0;
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        postToApi(user_id: "108", offset: pageNo, type: "popular")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UINib(nibName: "ImageListingTVC", bundle: nil), forCellReuseIdentifier: "ImageListingTVC")
        tableView.rowHeight = UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return imgListArr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ImageListingTVC", for: indexPath)as! ImageListingTVC
        
        if let imageUrlString = self.imgListArr[indexPath.row].xtImage,
           let imageUrl = URL(string: imageUrlString) {
            
            DispatchQueue.global().async {
                if let imageData = try? Data(contentsOf: imageUrl) {
                    DispatchQueue.main.async {
                        let image = UIImage(data: imageData)
                        cell.imgView.image = image
                        tableView.beginUpdates()
                        tableView.endUpdates()
                    }
                }
            }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "DetailScreenVC") as! DetailScreenVC
        detailVC.imageData = imgListArr[indexPath.row].xtImage!
        self.navigationController?.pushViewController(detailVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if let cachedHeight = cellHeightCache[indexPath] {
            return cachedHeight
        } else {
            if let imageUrlString = self.imgListArr[indexPath.row].xtImage,
               let imageUrl = URL(string: imageUrlString),
               let imageData = try? Data(contentsOf: imageUrl),
               let image = UIImage(data: imageData) {
                
                let aspectRatio = image.size.height / image.size.width
                let cellWidth = tableView.frame.width
                let cellHeight = cellWidth * aspectRatio
                
                cellHeightCache[indexPath] = cellHeight
                
                return cellHeight
            }
            
            
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.lightGray
        let button = UIButton(type: .system)
        button.setTitle("Load More", for: .normal)
        button.addTarget(self, action: #selector(loadMoreButtonTapped), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: 40)
        footerView.addSubview(button)
        
        return footerView
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 40
    }
    
    @objc func loadMoreButtonTapped() {
        pageNo+=1;
        postToApi(user_id: "108", offset: pageNo, type: "popular")
    }
    
    
    func postToApi(user_id: String, offset: Int, type: String) {
        let url = URL(string: "http://dev3.xicom.us/xttest/getdata.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let parameters: [String: Any] = [
            "user_id": user_id,
            "offset": offset,
            "type": type
        ]
        
        let parameterString = parameters.map { key, value in
            return "\(key)=\(value)"
        }.joined(separator: "&")
        
        request.httpBody = parameterString.data(using: .utf8)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let jsonResponse = try JSONDecoder().decode(ImageListingModel.self, from: data)
                self.imgListArr.append(contentsOf: jsonResponse.images!)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let parsingError {
                print("Error parsing JSON: \(parsingError.localizedDescription)")
            }
        }
        
        task.resume()
    }
    
    
    
}
