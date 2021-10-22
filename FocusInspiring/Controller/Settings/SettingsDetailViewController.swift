//
//  SettingsDetailViewController.swift
//  FocusInspiring
//
//  Created by Arno Seidel on 17.06.21.
//  Copyright © 2021 Arno Seidel. All rights reserved.
//

import UIKit
import WebKit


// MARK: SettingsDetailViewController: UIViewController

class SettingsDetailViewController: UIViewController {

    // MARK: - Properties

    var requestedPage: String?

    @IBOutlet weak var webView: WKWebView!


    // MARK: - Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        // Open requested resource
        if requestedPage == "About" {
            guard let urlPath = Bundle.main.url(forResource: "2021-09-01_LegalNotice_en_raw", withExtension: "html") else {
                track("GUARD FAILED: Local URL not found")
                return
            }

            webView.load(URLRequest(url: urlPath))

        } else {
            track("Requested page not found")
        }
    }
}
