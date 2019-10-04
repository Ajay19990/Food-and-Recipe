//
//  SearchResultsViewController.swift
//  Food and Recipe
//
//  Created by Ajay Choudhary on 03/10/19.
//  Copyright © 2019 Ajay Choudhary. All rights reserved.
//

import UIKit

class SearchResultsViewController: UIViewController {
    
    var searchQuery: String!
    var searchedRecipes = [SearchedRecipes]()
    let tableView = UITableView()
    var activityIndicatorContainer: UIView!
    var activityIndicator: UIActivityIndicatorView!
    
    override func loadView() {
        super.loadView()
        setup()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActivityIndicator()
        showActivityIndicator(show: true)
        SpoonacularClient.search(query: searchQuery) { (searchedRecipes) in
            self.showActivityIndicator(show: false)
            if searchedRecipes.count == 0 {
                DispatchQueue.main.async {
                    self.presentAlert(title: "Unable to search at the moment", message: "")
                }
            } else {
                self.searchedRecipes = searchedRecipes
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
    }
    
    private func setup() {
        self.title = "Results for \(searchQuery!)"
        setupTableView()
    }
    
    private func setupTableView() {
        view.addSubview(tableView)
        
        tableView.register(RecipeSearchCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    private func setupActivityIndicator() {
            activityIndicatorContainer = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
            activityIndicatorContainer.center.x = view.center.x
            activityIndicatorContainer.center.y = view.center.y
            activityIndicatorContainer.backgroundColor = UIColor.black
            activityIndicatorContainer.alpha = 0.8
            activityIndicatorContainer.layer.cornerRadius = 10
          
            // Configure the activity indicator
            activityIndicator = UIActivityIndicatorView()
            activityIndicator.hidesWhenStopped = true
            activityIndicator.style = UIActivityIndicatorView.Style.whiteLarge
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false
            activityIndicatorContainer.addSubview(activityIndicator)
            view.addSubview(activityIndicatorContainer)
            
            // Constraints
            activityIndicator.centerXAnchor.constraint(equalTo: activityIndicatorContainer.centerXAnchor).isActive = true
            activityIndicator.centerYAnchor.constraint(equalTo: activityIndicatorContainer.centerYAnchor).isActive = true
    }
    
    private func showActivityIndicator(show: Bool) {
      if show {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
      } else {
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.activityIndicatorContainer.removeFromSuperview()
            }
        }
    }
    
}

extension SearchResultsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchedRecipes.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! RecipeSearchCell
        let recipe = searchedRecipes[indexPath.row]
        cell.titleLabel.text = recipe.title
        cell.recipeImageView.image = UIImage(named: "imagePlaceholder")
        SpoonacularClient.downloadRecipeImage(imageURL: recipe.image) { (image) in
            DispatchQueue.main.async {
                cell.recipeImageView.image = image
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let id = searchedRecipes[indexPath.row].id
        self.setupActivityIndicator()
        self.showActivityIndicator(show: true)
        SpoonacularClient.getUserSearchedRecipe(id: id) { (recipe, dataFetched) in
            if !dataFetched {
                self.showActivityIndicator(show: true)
                return
            }
            self.showActivityIndicator(show: false)
            DispatchQueue.main.async {
                let detailVC = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
                detailVC.recipe = recipe
                self.navigationController?.pushViewController(detailVC, animated: true)
            }
        }
    }
    
}