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

protocol LanguageSelectionProtocol {
    func userChangeLanguage()
}

protocol LanguageSelectionModelProtocol {
    func getCurrenLenguage() -> String
    func setCurrentLocale(key: String)
    func getLenguages() -> Observable<[ItemLocale]>
}

class LanguageSelectionView: UIView {
    
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var languageTableView: UITableView!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    var parentViewController: UIViewController?
    var delegateOutput: LanguageSelectionProtocol?
    var viewModel: LanguageSelectionModelProtocol?
    var currentLanguageSelected: String?
    
    private var disposeBag = DisposeBag()
    
    class func initWithParentViewController(viewController: UIViewController, viewModel: LanguageSelectionModelProtocol, delegateOutput: LanguageSelectionProtocol) {
        
        guard let languageSelectionView = UINib(nibName: "LanguageSelectionView", bundle: nil)
                .instantiate(withOwner: nil, options: nil)[0] as? LanguageSelectionView else {
            return
        }
        
        let newFrame = CGRect(x: viewController.view.frame.origin.x,
                              y: viewController.view.frame.origin.y,
                              width: viewController.view.frame.width * 92 / 100,
                              height: viewController.view.frame.height * 85 / 100)
        languageSelectionView.frame = newFrame
        languageSelectionView.center = viewController.view.center
        viewController.view.addSubview(languageSelectionView)
        viewController.view.bringSubviewToFront(languageSelectionView)
        
        //Resolved warning from tableView
        languageSelectionView.languageTableView.layoutIfNeeded()
        
        languageSelectionView.parentViewController = viewController
        languageSelectionView.viewModel = viewModel
        
        languageSelectionView.initValues()
        
        languageSelectionView.delegateOutput = delegateOutput
    }
    
    @IBAction func onCancelAction(_ sender: Any) {
        removePopUpView()
    }
    
    @IBAction func onAcceptButton(_ sender: Any) {
        
        if let languageKeySelected = self.currentLanguageSelected,
           languageKeySelected != viewModel?.getCurrenLenguage() {
            
            parentViewController?.showAlertCancelContinue(title: "LOCALE_CHANGE_LANGUAGE".localized,
                                                          message: "LOCALE_CHANGE_WARNING".localized,
                                                          buttonOkTitle: "ALERT_OK_BUTTON".localized,
                                                          buttonCancelTitle: "ALERT_CANCEL_BUTTON".localized,
                                                          buttonOkVoiceover: "ACC_BUTTON_ALERT_OK".localized,
                                                          buttonCancelVoiceover: "ACC_BUTTON_ALERT_CANCEL".localized,
                                                          okHandler: { [weak self]_ in
                                                            self?.viewModel?.setCurrentLocale(key: languageKeySelected)
                                                            self?.delegateOutput?.userChangeLanguage()
                                                          }, cancelHandler: { _ in
                                                            //Nothing to do here
                                                          })
        } else {
            removePopUpView()
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
        
        self.cancelButton.setTitle("ALERT_CANCEL_BUTTON".localized, for: .normal)
        
        currentLanguageSelected = self.viewModel?.getCurrenLenguage()
        
        configTableView()
        
        setupAccessibility()
    }
    
    private func configTableView() {
        
        languageTableView.register(UINib(nibName: "LanguageTableViewCell", bundle: nil), forCellReuseIdentifier: "LanguageTableViewCell")
        
        self.viewModel?.getLenguages()
            .flatMap(generateTransformation).subscribe(onNext: { [weak self] (value) in
                self?.setDataSourceCell(totalLanguages: value)
            })
            .disposed(by: disposeBag)
        
        //Logic to selected item
        languageTableView.rx.itemSelected
            .subscribe(onNext: { [weak self] indexPath in
                let cell = self?.languageTableView.cellForRow(at: indexPath) as? LanguageTableViewCell
                self?.currentLanguageSelected = cell?.keyModel
            }).disposed(by: disposeBag)
    }
    
    func setDataSourceCell(totalLanguages: Int) {
        self.viewModel?.getLenguages()
            .bind(to: languageTableView.rx.items(cellIdentifier: "LanguageTableViewCell", cellType: LanguageTableViewCell.self)) {
                [weak self] row, element, cell in
                
                cell.setupModel(title: element.description, key: element.id   , totalItems: totalLanguages, indexItem: row)
                
                if (self?.currentLanguageSelected == element.id) {
                    self?.languageTableView.selectRow(at: IndexPath(row: row, section: 0), animated: false, scrollPosition: .none)
                }
            }.disposed(by: disposeBag)
    }
    
    func generateTransformation(val: [ItemLocale]) -> Observable<Int> {
        return Observable.just(val.count)
    }
    
    private func removePopUpView() {
        for view in parentViewController?.view.subviews ?? [] where view.tag == 1111 {
            view.fadeOut { (_) in
                view.removeFromSuperview()
            }
        }
    }
}
