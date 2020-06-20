//
//  StrechyTableHeaderView.swift
//  Note_WeThree
//
//  Created by user173890 on 6/19/20.
//  Copyright © 2020 Chaitanya Sanoriya. All rights reserved.
//

import Foundation
import UIKit

class StrechyTableHeaderView: UIView {
    var labelViewHeight = NSLayoutConstraint()
    var labelViewBottom = NSLayoutConstraint()
    
    var containerView: UIView!
    var labelView: UILabel!
    
    var containerViewHeight = NSLayoutConstraint()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        createViews()
        
        setViewConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func createViews() {
        // Container View
        containerView = UIView()
        self.addSubview(containerView)
        
        // ImageView for background
        labelView = UILabel()
        labelView.clipsToBounds = true
        labelView.backgroundColor = .yellow
        labelView.contentMode = .scaleAspectFill
        containerView.addSubview(labelView)
    }
    
    func setViewConstraints() {
        // UIView Constraints
        NSLayoutConstraint.activate([
            self.widthAnchor.constraint(equalTo: containerView.widthAnchor),
            self.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            self.heightAnchor.constraint(equalTo: containerView.heightAnchor)
        ])
        
        // Container View Constraints
        containerView.translatesAutoresizingMaskIntoConstraints = false
        
        containerView.widthAnchor.constraint(equalTo: labelView.widthAnchor).isActive = true
        containerViewHeight = containerView.heightAnchor.constraint(equalTo: self.heightAnchor)
        containerViewHeight.isActive = true
        
        // ImageView Constraints
        labelView.translatesAutoresizingMaskIntoConstraints = false
        labelViewBottom = labelView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor)
        labelViewBottom.isActive = true
        labelViewHeight = labelView.heightAnchor.constraint(equalTo: containerView.heightAnchor)
       labelViewHeight.isActive = true
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        containerViewHeight.constant = scrollView.contentInset.top
        let offsetY = -(scrollView.contentOffset.y + scrollView.contentInset.top)
        containerView.clipsToBounds = offsetY <= 0
        labelViewBottom.constant = offsetY >= 0 ? 0 : -offsetY / 2
        labelViewHeight.constant = max(offsetY + scrollView.contentInset.top, scrollView.contentInset.top)
    }
}
