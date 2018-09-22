//
//  CellView.swift
//  25
//
//  Created by Ruslan Gritsenko on 19.09.2018.
//  Copyright © 2018 Ruslan Gritsenko. All rights reserved.
//

import UIKit

class CellView: UIView {
    
    public var number: Int!
    public var color: UIColor!

    private lazy var cellView: UIView = {
        let view = UIView()
        view.backgroundColor = color
        view.layer.cornerRadius = 6.0
        return view
    }()

}
