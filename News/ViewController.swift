//
//  ViewController.swift
//  News
//
//  Created by Luka Cefarin on 08/01/2021.
//

import UIKit

class NewsListViewController: UITableViewController {
    
    private let newsRepostiory: NewsRepository = NewsRepository()
    private var newsList: [NewsObject] = []
    
    private lazy var refreshIndicator: UIRefreshControl = {
        let refreshIndicator = UIRefreshControl()
        refreshIndicator.addTarget(self, action: #selector(self.refreshIndicatorTriggered), for: .valueChanged)
        refreshIndicator.attributedTitle = NSAttributedString(string: "Loading...")
        return refreshIndicator
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupTableView()
        self.getNews()
    }
    
    @objc private func refreshIndicatorTriggered(_ sender: UIRefreshControl) {
        self.refreshIndicator.endRefreshing()
    }

    private func setupTableView() {
        self.tableView.refreshControl = self.refreshIndicator
        self.tableView.separatorStyle = .none
    }
    
    private func displayGettingNewsFailedAlert() {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Upss, something went wrong!", message: "Please try again later.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(action)
            self.present(alert, animated: true)
        }
    }
    
    private func refreshMannualy() {
        DispatchQueue.main.async {
            self.refreshControl!.sizeToFit()
            let top = self.tableView.adjustedContentInset.top
            let y = self.refreshControl!.frame.maxY + top
            self.tableView.setContentOffset(CGPoint(x:0, y: -y), animated:true)
            self.refreshControl!.beginRefreshing()
        }
    }
}

extension NewsListViewController {
    
    // MARK: - Populate methods
    
    private func getNews() {
        let newsFetchParameters: NewsRepository.FetchParameters = .init()
        self.refreshMannualy()
        _ = self.newsRepostiory.fetchNews(withParameters: newsFetchParameters) { [weak self] (result) in
            switch result {
            case .failure(_):
                self?.displayGettingNewsFailedAlert()
            case .success(let news):
                self?.newsList = news
                let indexPathsForInsertion: [IndexPath] = news.enumerated().map { IndexPath(row: $0.offset, section: 0) }
                self?.inserRows(withIndexPaths: indexPathsForInsertion)
               
            }
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
            }
        }
    }
    
    func inserRows(withIndexPaths indexPaths: [IndexPath]) {
        DispatchQueue.main.async {
            self.tableView.insertRows(at: indexPaths, with: .automatic)
        }
    }
}

extension NewsListViewController {
    
    // MARK: - Datasource
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.newsList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NewsCellView.newsCellIdentifier, for: indexPath) as? NewsCellView else {
            fatalError()
        }
        let newsItem = newsList[indexPath.row]
        cell.frontImageView?.image = UIImage(systemName: "photo")
        cell.titleLabel?.text = newsItem.title
        cell.displayFrontImage(withImageUrl: newsItem.imageUrl)
        return cell
    }
}

