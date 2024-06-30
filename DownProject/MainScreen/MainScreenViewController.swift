//
//  MainScreenViewController.swift
//  DownProject
//
//  Created by Gohar Vardanyan on 7/1/24.
//

import UIKit
import Combine

final class MainScreenViewController: UIViewController, UITabBarDelegate {
    @IBOutlet private weak var myLocationButton: UIButton!
    @IBOutlet private weak var profilesViewContainer: UIView!
    @IBOutlet private weak var bottomTabBar: UITabBar!
    @IBOutlet private weak var topBarContainer: UIView!
    @IBOutlet private weak var filtersContainer: UIView!

    private var profilesCollectionViewHandler: ProfilesCollectionViewHandler?
    private var filtersCollectionViewHandler: FiltersCollectionViewHandler?
    private var activityIndicator: UIActivityIndicatorView?
    private var errorHUD: UIView?
    private var emptyPrifilesView: EmptyView?
    
    private let screenViewModel = MainScreenViewModel()
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
                try await self.screenViewModel.loadFilters()
            } catch {
                // TODO: Handle error
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        filtersCollectionViewHandler?.selectFilterIfNeeded()
    }
    
    private func setupObservers() {
        screenViewModel.$downloadState.sink { [weak self] state in
            Task { @MainActor in
                guard let self = self else { return }
                switch state {
                case .loading:
                    self.profilesCollectionViewHandler?.profilesCollectionView?.isHidden = true
                    self.showLoading(true)
                case .finished:
                    self.showLoading(false)
                    self.createProfiles()
                case .failed(_):
                    self.showLoading(false)
                    self.showErrorHUD("Something went wrong")
                default:
                    break
                }
            }
        }.store(in: &cancellable)
        
        screenViewModel.$filters.sink { [weak self] _ in
            Task { @MainActor in
                self?.filtersCollectionViewHandler?.filtersCollectionView?.reloadData()
            }
        }.store(in: &cancellable)
    }
    
    private func setupBottomToolbar() {
        bottomTabBar.isTranslucent = false
        bottomTabBar.barTintColor = UIColor.black
        bottomTabBar.tintColor = UIColor.white
        bottomTabBar.unselectedItemTintColor = UIColor.lightGray
        bottomTabBar.selectedItem = bottomTabBar.items?[0]
        bottomTabBar.delegate = self
        
        let seperator = UIView(frame: .zero)
        seperator.backgroundColor = .darkGray
        bottomTabBar.addSubview(seperator)
        seperator.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            seperator.topAnchor.constraint(equalTo: bottomTabBar.topAnchor),
            seperator.leadingAnchor.constraint(equalTo: bottomTabBar.leadingAnchor),
            seperator.trailingAnchor.constraint(equalTo: bottomTabBar.trailingAnchor),
            seperator.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func setupMyProfileButton() {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "pic_profile")
        
        let button = UIButton(type: .system)
        button.configuration = config
        button.layer.cornerRadius = 15
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.white.cgColor
        button.clipsToBounds = true
        button.imageView?.contentMode = .scaleAspectFill
                
        topBarContainer.addSubview(button)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        button.imageView?.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            button.topAnchor.constraint(equalTo: topBarContainer.topAnchor, constant: 5),
            button.bottomAnchor.constraint(equalTo: topBarContainer.bottomAnchor, constant: -5),
            button.widthAnchor.constraint(equalToConstant: 30),
            button.leadingAnchor.constraint(equalTo: topBarContainer.leadingAnchor, constant: 10),
            button.imageView!.widthAnchor.constraint(equalToConstant: 30),
            button.imageView!.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    private func setupProfilesCollectionViewHandler() {
        profilesCollectionViewHandler = ProfilesCollectionViewHandler(viewModel: screenViewModel,
                                                                      profilesViewContainer: profilesViewContainer)
    }
    
    private func setupFilterCollectionViewHandler() {
        let filtersCollectionViewHandler = FiltersCollectionViewHandler(viewModel: screenViewModel,
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
        
        profilesCollectionViewHandler?.profilesCollectionView?.isHidden = false
        profilesCollectionViewHandler?.profilesCollectionView?.reloadData()
    }
    
    private func createEmptyView() {
        let emptyView = EmptyView(title: NSLocalizedString("Try another filter", comment: "") ,
                                  subtitle: NSLocalizedString("Tats's all for now, but don't worry, there are new singles joining every second. Try another filter or check back later", comment: ""),
                                  frame: .zero)
        emptyView.backgroundColor = .clear
        emptyView.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        
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
            container.layer.cornerRadius = 30
            container.layer.borderColor = UIColor.white.cgColor
            container.layer.borderWidth = 1
            container.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
            profilesViewContainer.addSubview(container)
            
            NSLayoutConstraint.activate([
                container.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
                container.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
                container.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor, constant: 20),
                container.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor, constant: -20),
                ])

                
            let indicator = UIActivityIndicatorView(style: .large)
            container.addSubview(indicator)
            indicator.hidesWhenStopped = true
            indicator.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            indicator.color = UIColor.white
            indicator.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                indicator.centerXAnchor.constraint(equalTo: container.centerXAnchor),
                indicator.centerYAnchor.constraint(equalTo: container.centerYAnchor)
            ])
            self.activityIndicator = indicator
            indicator.startAnimating()
        } else {
            activityIndicator?.stopAnimating()
            activityIndicator?.superview?.removeFromSuperview()
            activityIndicator = nil
        }
    }
    
    private func showErrorHUD(_ message: String) {
        let hud = UIView()
        hud.backgroundColor = UIColor.clear
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.backgroundColor = UIColor(red: 20/255, green: 20/255, blue: 20/255, alpha: 1)
        hud.translatesAutoresizingMaskIntoConstraints = false
        hud.layer.borderColor = UIColor.white.cgColor
        hud.layer.borderWidth = 1
        
        profilesViewContainer.addSubview(hud)
        self.errorHUD = hud
        
        let label = UILabel()
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = message
        label.translatesAutoresizingMaskIntoConstraints = false
        label.tag = 100
        hud.addSubview(label)
        
        let button = UIButton(type: .system)
        button.setTitle("Try again", for: .normal)
        button.backgroundColor = .clear
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.cgColor

        button.addTarget(self, action: #selector(retryButtonAction), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        hud.addSubview(button)

        NSLayoutConstraint.activate([
            hud.topAnchor.constraint(equalTo: profilesViewContainer.topAnchor),
            hud.bottomAnchor.constraint(equalTo: profilesViewContainer.bottomAnchor),
            hud.leadingAnchor.constraint(equalTo: profilesViewContainer.leadingAnchor, constant: 20),
            hud.trailingAnchor.constraint(equalTo: profilesViewContainer.trailingAnchor, constant: -20),

            label.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: hud.centerYAnchor, constant: -30),
            label.heightAnchor.constraint(equalToConstant: 40),
            label.widthAnchor.constraint(greaterThanOrEqualToConstant: 60),
            
            button.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 15),
            button.centerXAnchor.constraint(equalTo: hud.centerXAnchor),
            button.heightAnchor.constraint(equalToConstant: 40),
            button.widthAnchor.constraint(greaterThanOrEqualToConstant: 100)
        ])
    }
    
    @objc
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

