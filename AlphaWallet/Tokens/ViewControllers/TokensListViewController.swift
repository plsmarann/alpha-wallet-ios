//
//  TokensListViewController.swift
//  AlphaWallet
//
//  Created by PL Smarann Khadka on 18/06/2023.
//

import UIKit
import StatefulViewController
import Combine
import AlphaWalletFoundation
import FloatingPanel


class TokensListViewController: UIViewController {
    var tableView = UITableView()
    private let cellIdentifier = "TokenCell"
    var fromTokens: [TokenItem] = []
    var viewModel = TokensListViewModel()

    var floatingPanel: FloatingPanelController?
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.title = "Tokens"
            let closeButton = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(closeButtonTapped))
            navigationItem.rightBarButtonItem = closeButton
        
      
        setupTableView()
        fetchTokens()
        setupFloatingPanel()
    }
    



        init(viewModel: TokensListViewModel) {
            self.viewModel = viewModel
            super.init(nibName: nil, bundle: nil)
        }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
   
//    init() {
//        // ...
//        super.init(nibName: nil, bundle: nil) // Call the superclass designated initializer
//
//        // Set the title
//        navigationItem.title = "Tokens"
//
//        // Add a close button to the navigation bar
//        let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonTapped))
//        navigationItem.rightBarButtonItem = closeButton
//    }
//

    

   
    private func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
               tableView.dataSource = self
               tableView.delegate = self
               tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TokenCell")
               view.addSubview(tableView)

               tableView.translatesAutoresizingMaskIntoConstraints = false
               NSLayoutConstraint.activate([
                   tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                   tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
                   tableView.topAnchor.constraint(equalTo: view.topAnchor),
                   tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
               ])
    }
    private func setupFloatingPanel() {
           floatingPanel = FloatingPanelController()
           floatingPanel?.delegate = self

           let contentVC = UIViewController()
           floatingPanel?.set(contentViewController: contentVC)

           floatingPanel?.surfaceView.backgroundColor = .white
           floatingPanel?.surfaceView.cornerRadius = 12
            floatingPanel?.shouldDismissOnBackdrop = true
           addChild(floatingPanel!)
           view.addSubview(floatingPanel!.view)
           floatingPanel!.didMove(toParent: self)

           // Adjust the position and size of the floating panel
           floatingPanel?.surfaceView.frame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: 300)

           // Show the floating panel
           floatingPanel?.addPanel(toParent: self, animated: true)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(tapGesture)
       }
    private func fetchTokens() {
        viewModel.fetchTokens( limit: 100){ [weak self] tokens in
            DispatchQueue.main.async {
                self?.fromTokens = tokens
                self?.tableView.reloadData()
            }
            for token in tokens {
                    print("Token: \(token.symbol)")
                }
        }
    }
    
    @objc func viewTapped(_ sender: UITapGestureRecognizer) {
 
    }

}

extension TokensListViewController: UITableViewDataSource , UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var  count = self.viewModel.fromTokens.count
        return count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
        let token =  self.viewModel.fromTokens[indexPath.row]
        cell.textLabel?.text = token.name
        cell.detailTextLabel?.text = token.symbol
        return cell
    }
}
extension TokensListViewController: FloatingPanelControllerDelegate {
    func floatingPanel(_ viewController: FloatingPanelController, layoutFor newCollection: UITraitCollection) -> FloatingPanelLayout {
        return FloatingPanelBottomLayout()
    }
}
