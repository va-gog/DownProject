//
//  MainScreenViewController.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit
import Combine

final class MainScreenViewController: UIViewController, UITabBarDelegate {
    @IBOutlet private weak var bottomTabBar: UITabBar!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var filtersContainer: UIView!
    @IBOutlet private weak var profilesViewContainer: UIView!
    @IBOutlet private weak var myLocationButton: UIButton!

    private var profilesCollectionViewHandler: ProfilesCollectionViewManager?
    private var filtersCollectionViewHandler: FiltersCollectionViewManager?
    private var activityIndicator: UIActivityIndicatorView?
    private var errorHUD: ErrorHUDView?
    private var emptyPrifilesView: EmptyView?
    
    private let screenViewModel = MainScreenViewModel()
    private let theme = MainScreenViewTheme()
    private var cancellable: [AnyCancellable] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBottomToolbar()
        setupMyProfileButton()
        setupObservers()
        setupProfilesCollectionViewHandler()
        setupFilterCollectionViewHandler()
          
        Task {
            do {
               let url = Bundle.main.url(forResource: "Filters", withExtension: "json")
                try await self.screenViewModel.loadFilters(url: url)
            } catch {
                // TODO: Handle error
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupObservers() {
        screenViewModel.$downloadState.sink { [weak self] state in
            Task { @MainActor in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.profilesCollectionViewHandler?.profilesCollectionView.isHidden = true
                    self.showLoading(true)
                case .finished:
                    self.showLoading(false)
                case .failed(_):
                    self.showLoading(false)
                    self.showErrorHUD("Something went wrong")
                default:
                    break
                }
            }
        }.store(in: &cancellable)
        
        screenViewModel.$filters
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.filtersCollectionViewHandler?.filtersCollectionView.reloadData()
        }.store(in: &cancellable)
        
        screenViewModel.$profiles
            .dropFirst()
            .receive(on: DispatchQueue.main)
            .sink { models in
                    self.createProfiles()
        }.store(in: &cancellable)
    }
    
    private func setupBottomToolbar() {
        bottomTabBar.isTranslucent = false
        bottomTabBar.barTintColor = theme.bottomTabBarBackgorunColor
        bottomTabBar.tintColor = theme.bottomTabBarTintColor
        bottomTabBar.unselectedItemTintColor = theme.bottomTabBarUnselectedItemTintColor
        bottomTabBar.selectedItem = bottomTabBar.items?[0]
        bottomTabBar.delegate = self
        
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = theme.seperatorBackgroundColor
        bottomTabBar.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: bottomTabBar.topAnchor),
            seperator.leadingAnchor.constraint(equalTo: bottomTabBar.leadingAnchor),
            seperator.trailingAnchor.constraint(equalTo: bottomTabBar.trailingAnchor),
            seperator.heightAnchor.constraint(equalToConstant: theme.seperatorHeight)
        ])
    }
    
    func setupMyProfileButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: theme.myProfileImg)
        
        let button = UIButton(type: .system)
        button.configuration = config
        button.layer.cornerRadius = theme.myProfileButtonCornerRadius
        button.layer.borderWidth = theme.myProfileButtonBorderWidth
        button.layer.borderColor = theme.myProfileButtonBorderColor
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
                
        topBarContainer.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topBarContainer.topAnchor,
                                        constant: theme.myProfileButtonTopAnchor),
            button.bottomAnchor.constraint(equalTo: topBarContainer.bottomAnchor,
                                           constant: theme.myProfileButtonBottomAnchor),
            button.widthAnchor.constraint(equalToConstant: theme.myProfileButtonWidthAnchor),
            button.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor,
                                            constant: theme.myProfileButtonLeadingAnchor),
            button.imageView!.widthAnchor.constraint(equalToConstant: theme.myProfileButtonImageViewSize),
            button.imageView!.heightAnchor.constraint(equalToConstant: theme.myProfileButtonImageViewSize)
        ])
    }
    
    private func setupProfilesCollectionViewHandler() {
        profilesCollectionViewHandler = ProfilesCollectionViewManager(viewModel: screenViewModel,
                                                                      profilesViewContainer: profilesViewContainer)
    }
    
    private func setupFilterCollectionViewHandler() {
        let filtersCollectionViewHandler = FiltersCollectionViewManager(viewModel: screenViewModel,
                                                                        filtersViewContainer: filtersContainer)
        self.filtersCollectionViewHandler = filtersCollectionViewHandler
        filtersCollectionViewHandler.didSelectFilter = { [weak self] in
            self?.errorHUD?.removeFromSuperview()
            self?.errorHUD = nil
            self?.emptyPrifilesView?.removeFromSuperview()
            self?.emptyPrifilesView = nil
        }
    }
    
    private func createProfiles() {
        if screenViewModel.profiles.isEmpty {
            createEmptyView()
            return
        }
        
        profilesCollectionViewHandler?.profilesCollectionView.isHidden = false
        profilesCollectionViewHandler?.profilesCollectionView.reloadData()
    }
    
    private func createEmptyView() {
        let titles = ViewTexts()
        let emptyView = EmptyView(title: NSLocalizedString(titles.emptyViewTitle, comment: "") ,
                                  subtitle: NSLocalizedString(titles.emptyViewSubtitle, comment: ""),
                                  frame: .zero)
        emptyView.backgroundColor = MainScreenViewTheme.emptyViewBackgroundColor
        emptyView.layer.cornerRadius = theme.emptyViewCornerRadius
        emptyView.layer.borderColor = theme.emptyViewBorderColor
        emptyView.layer.borderWidth = theme.emptyViewBorderWidth
        
        profilesViewContainer.addSubview(emptyView)
        emptyView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            emptyView.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
            emptyView.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
            emptyView.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor, constant: 20),
            emptyView.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor, constant: -20),
        ])
        self.emptyPrifilesView = emptyView
    }
    
    private func showLoading(_ show: Bool) {
        if show {
            let container = UIView()
            container.backgroundColor = UIColor.clear
            container.translatesAutoresizingMaskIntoConstraints = false
            container.layer.cornerRadius = theme.emptyViewCornerRadius
            container.layer.borderColor = theme.emptyViewBorderColor
            container.layer.borderWidth = theme.emptyViewBorderWidth
            container.backgroundColor = MainScreenViewTheme.emptyViewBackgroundColor
            profilesViewContainer.addSubview(container)
            
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
                container.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor,
                                                   constant: theme.emptyViewVerticalInset),
                container.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor,
                                                    constant: -theme.emptyViewVerticalInset),
                ])

            let indicator = UIActivityIndicatorView(style: .large)
            indicator.hidesWhenStopped = true
            indicator.transform = theme.indicatorTransform
            indicator.color = theme.indicatorColor
            self.activityIndicator = indicator

            container.addSubview(indicator)

            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            
            
            indicator.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.superview?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    private func showErrorHUD(_ message: String) {
        let hud = ErrorHUDView(message: message, 
                               buttonTitle: NSLocalizedString(ViewTexts().retryButtonText,
                                                              comment: "")) {
            self.retryButtonAction()
        }
        hud.backgroundColor =  MainScreenViewTheme.emptyViewBackgroundColor
        hud.layer.cornerRadius = theme.emptyViewCornerRadius
        hud.layer.borderColor = theme.emptyViewBorderColor
        hud.layer.borderWidth = theme.emptyViewBorderWidth
        self.errorHUD = hud

        profilesViewContainer.addSubview(hud)
        
        hud.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hud.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
            hud.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
            hud.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor, 
                                         constant: theme.emptyViewVerticalInset),
            hud.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor,
                                          constant: -theme.emptyViewVerticalInset)
        ])
    }
    
    func retryButtonAction() {
        errorHUD?.removeFromSuperview()
        errorHUD = nil
        
        Task {
            let urlString = screenViewModel.filters[screenViewModel.selectedFilterIndex].profilesURL
            Task {
               await screenViewModel.downloadProfiles(urlString: urlString)
            }
        }
    }

    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        // TODO: Implement bottom tab bar actions
    }
}
