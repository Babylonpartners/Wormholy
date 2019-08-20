//
//  RequestCell.swift
//  Wormholy-iOS
//
//  Created by Paolo Musolino on 13/04/18.
//  Copyright © 2018 Wormholy. All rights reserved.
//

import UIKit

class RequestCell: UICollectionViewCell {
    
    @IBOutlet weak var codeLabel: WHLabel!
    @IBOutlet weak var hostLabel: WHLabel!
    @IBOutlet weak var pathLabel: WHLabel!
    @IBOutlet weak var queryLabel: WHLabel!
    @IBOutlet weak var durationLabel: WHLabel!
    
    func populate(request: RequestModel?){
        guard let request = request else { return }

        let color: UIColor

        switch request.code {
        case 200..<300:
            color = Colors.HTTPCode.Success
        case 300..<400:
            color = Colors.HTTPCode.Redirect
        case 400..<500:
            color = Colors.HTTPCode.ClientError
        case 500..<600:
            color = Colors.HTTPCode.ServerError
        default:
            color = Colors.HTTPCode.Generic
        }

        codeLabel.text = request.code != 0 ? String(request.code) : "..."
        codeLabel.borderColor = color
        codeLabel.textColor = color
        durationLabel.text = request.duration?.formattedMilliseconds() ?? ""


        let components = URLComponents(string: request.url)
        let schemeAndHost = NSMutableAttributedString()

        schemeAndHost.append(
            NSAttributedString(
                string: request.method.uppercased() + " ",
                attributes: [.foregroundColor: UIColor.black]
            )
        )

        if let host = components?.host {
            let scheme = components?.scheme.map { "\($0)://" } ?? ""
            schemeAndHost.append(NSAttributedString(string: scheme + host, attributes: [.foregroundColor: UIColor.lightGray]))
        }

        hostLabel.attributedText = schemeAndHost
        pathLabel.text = components?.path ?? ""
        queryLabel.text = components?.query.map { "?" + $0 } ?? ""
        queryLabel.isHidden = components?.query == nil
    }
}
