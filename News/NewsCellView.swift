//
//  NewsCellView.swift
//  News
//
//  Created by Luka Cefarin on 08/01/2021.
//

import UIKit

final class NewsCellView: UITableViewCell {
    
    static let newsCellIdentifier: String = "NewsCell"
    
    @IBOutlet weak var frontImageView: UIImageView?
    @IBOutlet weak var titleLabel: UILabel?
    
    func displayFrontImage(withImageUrl url: URL?) {
        guard let url = url else {
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] (data, response, error) in
            if let data = data {
                DispatchQueue.main.async {
                    self?.frontImageView?.image = UIImage(data: data)
                }
            }
        }.resume()
    }
    
}
