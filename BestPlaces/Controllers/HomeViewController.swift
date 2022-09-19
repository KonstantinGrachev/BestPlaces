import UIKit
import RealmSwift

class HomeViewController: UIViewController {
    
    //MARK: - constants
    
    enum Constants {
        static let heightForRow: CGFloat = 85
    }
    
    //MARK: - properties

    private var places: Results<PlaceModel>! = realm.objects(PlaceModel.self)
    private var filteredPlaces: Results<PlaceModel>!
    private var isSortedAscending = true
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else { return false }
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: - UI objects
    
    private let searchController = UISearchController(searchResultsController: nil)
    
    private lazy var segmentedControl: UISegmentedControl = {
        let segmentedControl = UISegmentedControl(items: ["Date", "Name"])
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.addTarget(self, action: #selector(segmentedControlChanged), for: .valueChanged)
        segmentedControl.backgroundColor = .secondarySystemBackground
        segmentedControl.selectedSegmentIndex = 0
        return segmentedControl
    }()
    
    private let placesTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = MainConstants.sideIndentation
        tableView.separatorInset.right = MainConstants.sideIndentation
        tableView.backgroundColor = .secondarySystemBackground
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - viewDidLoad
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationController()
        setupViews()
        setDelegates()
        setupSearchController()
        setConstraints()
        //        print(Realm.Configuration.defaultConfiguration.fileURL!)
        
    }
    
    //MARK: - setup view controller
    
    private func setupViews() {
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(segmentedControl)
        view.addSubview(placesTableView)
    }
    
    private func setupNavigationController() {
        navigationItem.title = "Best Places"
        navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "arrow.up.arrow.down.square"), style: .plain, target: self, action: #selector(sortButtonTapped))
    }
    
    private func setDelegates() {
        placesTableView.delegate = self
        placesTableView.dataSource = self
        placesTableView.register(PlaceCell.self, forCellReuseIdentifier: PlaceCell.placeCellId)
    }
    
    private func setupSearchController() {
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search"
        navigationItem.searchController = searchController
        definesPresentationContext = true
    }
    
    //MARK: - @IBActions
    
    @IBAction private func addButtonTapped() {
        let addPlaceController = NewPlaceViewController()
        addPlaceController.delegate = self
        navigationController?.pushViewController(addPlaceController, animated: true)
    }
    
    @IBAction private func sortButtonTapped() {
        
        isSortedAscending.toggle()
        
        if isSortedAscending {
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "arrow.up.arrow.down.square")
        } else {
            navigationItem.leftBarButtonItem?.image = UIImage(systemName: "arrow.up.arrow.down.square.fill")
        }
        segmentedControlChanged()
    }
    
    @IBAction private func segmentedControlChanged() {
        if segmentedControl.selectedSegmentIndex == 0 {
            places = places.sorted(byKeyPath: "date", ascending: isSortedAscending)
        } else {
            places = places.sorted(byKeyPath: "name", ascending: isSortedAscending)
            
        }
        placesTableView.reloadData()
    }
}

//MARK: - table view

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredPlaces.count
        }
        return places.count
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        Constants.heightForRow
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = placesTableView.dequeueReusableCell(withIdentifier: PlaceCell.placeCellId, for: indexPath) as? PlaceCell else { return UITableViewCell() }
        
        if isFiltering {
            cell.configure(model: filteredPlaces[indexPath.row])
        } else {
            cell.configure(model: places[indexPath.row])
        }
        
        return cell
    }
    
    //MARK: Delete cell
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        var place = places[indexPath.row]
        if isFiltering {
            place = filteredPlaces[indexPath.row]
        }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, _) in
            StorageManager.deletePlace(place)
            tableView.deleteRows(at: [indexPath], with: .none)
        }
        deleteAction.image = UIImage(systemName: "trash")
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    //MARK: - Show details and editing place
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let addNewPlaceViewController = NewPlaceViewController()
        addNewPlaceViewController.currentPlace = places[indexPath.row]
        if isFiltering {
            addNewPlaceViewController.currentPlace = filteredPlaces[indexPath.row]
        }
        
        addNewPlaceViewController.delegate = self
        navigationController?.pushViewController(addNewPlaceViewController, animated: true)
    }
}

//MARK: - constraints

extension HomeViewController {
    private func setConstraints() {
        
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        NSLayoutConstraint.activate([
            placesTableView.topAnchor.constraint(equalTo: segmentedControl.bottomAnchor),
            placesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            placesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            placesTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

//MARK: - delegate AddViewController

extension HomeViewController: NewPlaceViewControllerDelegate {
    func reloadHomeTableView() {
        placesTableView.reloadData()
    }
}

//MARK: - delegate search controller
extension HomeViewController: UISearchControllerDelegate, UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let text = searchController.searchBar.text else { return }
        filterContentForSearchText(text)
    }
    
    private func filterContentForSearchText(_ searchText: String) {
        filteredPlaces = places.filter("name CONTAINS[c] %@ OR location CONTAINS[c] %@", searchText, searchText)
        placesTableView.reloadData()

    }
}
