//
//  TokensListCoordinator.swift
//  AlphaWallet
//
//  Created by PL Smarann Khadka on 20/06/2023.
//

import UIKit

class TokensListCoordinator: Coordinator {
    var coordinators: [Coordinator] = []
    
    private let navigationController: UINavigationController
    private var floatingPanelController: FloatingPanelController?


   
    init(
         navigationController: UINavigationController) {
        self.navigationController = navigationController
     
    }
    
    func start() {
        let viewModel = TokensListViewModel()
        let tokensListViewController = TokensListViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: tokensListViewController)
        let panelController = FloatingPanelController()
        panelController.delegate = self
        panelController.shouldDismissOnBackdrop = true
        panelController.set(contentViewController: navigationController)
        
        self.navigationController.present(panelController, animated: true, completion: nil)
        floatingPanelController = panelController
    }


    @objc private func closeButtonTapped(_ sender: UIBarButtonItem) {
        floatingPanelController?.removeFromParent()
    }
}


extension TokensListCoordinator: FloatingPanelControllerDelegate {
    // Implement the necessary delegate methods for the floating panel controller
    // (e.g., handle panel presentation, layout, behavior, etc.)
    func floatingPanelShouldRemove(_ vc: FloatingPanelController) -> Bool {
        return true
    }
}
    

