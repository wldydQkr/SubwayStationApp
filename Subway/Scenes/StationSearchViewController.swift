//
//  StationSearchViewController.swift
//  Subway
//
//  Created by 박지용 on 2022/04/27.
//

import Alamofire
import SnapKit
import UIKit

class StationSearchViewController: UIViewController {
    private var numberOfCell: Int = 0 // 임의의 값
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.isHidden = true
        
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // 메소드가 분리되면 상세코드는 몰라도 메소드 이름으로 코드 순서를 구분할 수 있다.
        setNavigationItems()
        setTableViewLayout()
        
        requestStationName()
    }
    
    private func setNavigationItems() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "지하철 도착 정보"
        
        let searchController = UISearchController()
        searchController.searchBar.placeholder = "지하철 역을 입력해주세요."
        searchController.obscuresBackgroundDuringPresentation = false // SearchBar가 선택이 되었을 때 배경을 흐리게 해줌
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
    }
    
    private func setTableViewLayout() {
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview()} // 전체 UIViewController에 딱맞게 사이즈 됨
    }
    
    private func requestStationName() {
        let urlString = "http://openapi.seoul.go.kr:8088/sample/json/SearchInfoBySubwayNameService/1/5/서울역"
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "").responseDecodable(of: StationResponseModel.self) { response in
            guard case .success(let data) = response.result else { return }
            
            print(data.stations)
        }
        .resume()
    }
    
}

extension StationSearchViewController: UISearchBarDelegate { // 특정 행동의 동작을 위임해주는 프로토콜
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { // 유저가 수정을 시작했을 때 불려짐
        numberOfCell = 10
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { // 유저가 수정을 마쳤을 때 불려짐
        numberOfCell = 0
        tableView.isHidden = true
    }
}

extension StationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = StationDetailViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension StationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfCell
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(indexPath.item)"
        
        return cell
    }
}
