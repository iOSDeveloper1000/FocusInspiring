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
        switch requestedPage {
        case "Contribution":
            print("@todo Contribution page")

        case "About":
            guard let urlPath = Bundle.main.url(forResource: "2021-09-01_LegalNotice_en_raw", withExtension: "html") else {
                track("GUARD FAILED: Local URL not found")
                return
            }
            webView.load(URLRequest(url: urlPath))

        default:
            track("UNKNOWN DEFAULT: Requested page not found")
        }
    }
}
