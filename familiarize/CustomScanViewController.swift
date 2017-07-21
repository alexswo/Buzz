//
//  ViewController.swift
//  DemoSample
//
//  Created by Julian Gruber on 06/03/2017.
//  Copyright © 2017 Quikkly Ltd. All rights reserved.
//

import UIKit
import Quikkly

class CustomScanViewController: ScanViewController {
    
    override init() {
        super.init()
        
        self.title = "Scan"
    }
    
    // MARK: - ScanViewDelegate
    
    func scanView(_ scanView: ScanView, didDetectScannables scannables: [Scannable]) {
        if let scannable = scannables.first { // use first scannable
            // handle (in this case logging the scannable's value)
            print("Found scannable code: \(scannable.value)")
            scannable.getMappedData({(data) in
                if let mappedData = data {
                    print(mappedData)
                } else {
                    print("failure")
                }
            })
        }
    }
}

