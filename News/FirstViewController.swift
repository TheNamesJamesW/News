//
//  FirstViewController.swift
//  News
//
//  Created by James Wilkinson on 17/11/2016.
//  Copyright © 2016 James Wilkinson. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
//        StateController.instance.sub
        StateController.instance.downloadFeedArticles()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

