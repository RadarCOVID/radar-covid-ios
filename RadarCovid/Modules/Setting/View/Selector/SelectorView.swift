//

// Copyright (c) 2020 Gobierno de España
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//
// SPDX-License-Identifier: MPL-2.0
//

import UIKit
import RxSwift
import RxCocoa

protocol SelectorProtocol {
    func userSelectorSelected(selectorItem: SelectorItem, completionCloseView: @escaping (Bool) -> Void)
    func hiddenSelectorSelectionView()
}

class SelectorView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var selectorTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    var parentViewController: UIViewController?
    var delegateOutput: SelectorProtocol?
    
    var getArray:() -> (Observable<[SelectorItem]>) = {
        return Observable.create { observer in
            
            observer.onNext([])
            observer.onCompleted()
            
            return Disposables.create {
            }
        }
    }
    var getSelectedItem:() -> (Observable<SelectorItem>) = {
        return Observable.create { observer in
            
            observer.onNext(SelectorItem(id: "", description: "", objectOrigin: ""))
            observer.onCompleted()
            
            return Disposables.create {
            }
        }
    }
    
    var itemInitSelected: SelectorItem?
    var itemSelected: SelectorItem?
    
    private var disposeBag = DisposeBag()
    
    class func initWithParentViewController(viewController: UIViewController,
                                            title: String,
                                            getArray:@escaping () -> Observable<[SelectorItem]>,
                                            getSelectedItem:@escaping () -> Observable<SelectorItem>,
                                            delegateOutput: SelectorProtocol) {
        
        guard let selectorView = UINib(nibName: "SelectorView", bundle: nil)
                .instantiate(withOwner: nil, options: nil)[0] as? SelectorView else {
            return
        }
        selectorView.setFontTextStyle()
        let newFrame = CGRect(x: viewController.view.frame.origin.x,
                              y: viewController.view.frame.origin.y,
                              width: viewController.view.frame.width * 92 / 100,
                              height: viewController.view.frame.height * 85 / 100)
        selectorView.frame = newFrame
        selectorView.center = viewController.view.center
        viewController.navigationController?.topViewController?.view.addSubview(selectorView)
        viewController.navigationController?.topViewController?.view.bringSubviewToFront(selectorView)
        
        //Resolved warning from tableView
        selectorView.selectorTableView.layoutIfNeeded()
        
        selectorView.parentViewController = viewController
        selectorView.titleLabel.text = title
        selectorView.getArray = getArray
        selectorView.getSelectedItem = getSelectedItem
        
        selectorView.initValues()
        
        selectorView.delegateOutput = delegateOutput
    }
    
    @IBAction func onCancelAction(_ sender: Any) {
        removePopUpView()
    }
    
    @IBAction func onAcceptButton(_ sender: Any) {
        if let itemSelected = self.itemSelected {
            self.delegateOutput?.userSelectorSelected(selectorItem: itemSelected, completionCloseView: { [weak self] (isCloseView) in
                if isCloseView {
                    self?.removePopUpView()
                }
            })
        }
    }
    
    private func setupAccessibility() {
        
        acceptButton.isAccessibilityElement = true
        acceptButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        acceptButton.accessibilityHint = "ACC_BUTTON_ALERT_ACCEPT".localized
        
        cancelButton.isAccessibilityElement = true
        cancelButton.accessibilityTraits.insert(UIAccessibilityTraits.button)
        cancelButton.accessibilityHint = "ACC_BUTTON_ALERT_CANCEL".localized
    }
    
    private func initValues() {
        
        containerView.layer.masksToBounds = true
        containerView.layer.cornerRadius = 8
        
        cancelButton.layer.borderColor = UIColor.deepLilac.cgColor
        
        self.acceptButton.setTitle("ACC_BUTTON_ACCEPT".localized, for: .normal)
        self.cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        getSelectedItem().subscribe(onNext: { [weak self] (value) in
            self?.itemInitSelected = value
            self?.itemSelected = value
        }).disposed(by: disposeBag)

        configTableView()
        
        setupAccessibility()
    }
    
    private func configTableView() {
        
        selectorTableView.register(UINib(nibName: "SelectorTableViewCell", bundle: nil), forCellReuseIdentifier: "SelectorTableViewCell")
        
        getArray()
            .flatMap(generateTransformation).subscribe(onNext: { [weak self] (value) in
                self?.setDataSourceCell(totalSelectors: value)
            })
            .disposed(by: disposeBag)
        
        //Logic to selected item
        selectorTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.selectorTableView.cellForRow(at: indexPath) as? SelectorTableViewCell
                self?.itemSelected = cell?.itemModel
            }).disposed(by: disposeBag)
    }
    
    func setDataSourceCell(totalSelectors: Int) {
        getArray()
            .bind(to: selectorTableView.rx.items(cellIdentifier: "SelectorTableViewCell", cellType: SelectorTableViewCell.self)) {
                [weak self] row, element, cell in
                
                cell.setupModel(itemModel: element, totalItems: totalSelectors, indexItem: row)
                
                if (self?.itemSelected?.id == element.id) {
                    self?.selectorTableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }.disposed(by: disposeBag)
    }
    
    func generateTransformation(val: [SelectorItem]) -> Observable<Int> {
        return Observable.just(val.count)
    }
    
    private func removePopUpView() {
        self.delegateOutput?.hiddenSelectorSelectionView()
        for view in parentViewController?.navigationController?.topViewController?.view.subviews ?? [] where view.tag == 1111 {
            view.fadeOut { (_) in
                view.removeFromSuperview()
            }
        }
    }
}
