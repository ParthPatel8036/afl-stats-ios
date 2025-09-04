//
//  LoaderController.swift
//  AFL
//
//  Created by Parth on 20/05/2025.
//

import UIKit

class LoaderController: UIViewController {
    
    @IBOutlet weak var loadingView: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingView.fadeIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        loadingView.alpha = 0
    }
}
