//
//  StationSearchViewController.swift
//  Subway
//
//  Created by 박지용 on 2022/04/27.
//

import Alamofire
import SnapKit
import UIKit

class StationSearchViewController: UIViewController, UIScrollViewDelegate {
    var scrollView: UIScrollView!
    var imageView: UIImageView!
    
    var pinchGesture = UIPinchGestureRecognizer()
    
    private var stations:[Station] = []
    
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
        
        let frameSize = view.bounds.size
        scrollView = UIScrollView(frame: CGRect(origin: CGPoint.zero, size: frameSize))
        
        let image = UIImage(named: "seoul_subway.png")
        imageView = UIImageView(image: image)
        scrollView.contentSize = imageView.bounds.size
        
        scrollView.addSubview(imageView)
        view.addSubview(scrollView)
        
        // 텝 횟수에 따라서 동작 결정
        let doubleTap = UITapGestureRecognizer(target: self, action: #selector(self.tapToZoom))
        doubleTap.numberOfTapsRequired = 2
        doubleTap.numberOfTouchesRequired = 1
        
        // 더블텝 제스쳐를 scrllView 상위로 올렷다, 컨테이너 밖으로 벗어나면 터치가 안됨 ㅠㅠ
        scrollView.addGestureRecognizer(doubleTap)
        
        // 메소드가 분리되면 상세코드는 몰라도 메소드 이름으로 코드 순서를 구분할 수 있다.
        setNavigationItems()
        setTableViewLayout()
        
    }
    
    // 더블탭 기능, delegate 사용해서, addTaget 으로 사용함, 엄밀하게 더블텝을 위한것보다는, 델리게이트를 이용해서, 불려 오는 함수에 조건을 넣어서 기능을 구현했다.
    @objc func tapToZoom(_ gestureRecognizer: UIGestureRecognizer) {
        print("줌..")
        
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 3.0
        
        scrollView.delegate = self
        
        // 더블탭 간단 하게 구현
        if scrollView.zoomScale == CGFloat(1) {
            scrollView.setZoomScale(3, animated: true)
        }else {
            scrollView.setZoomScale(1, animated: true)
        }
    }
    
    // Pinch Gesture 줌 인, 아웃 가능, 사실상 핵심 기능. 이미지뷰를 반환할때, 하이라키 구조와 컨테이너 개념을 알고 있어야 한다. Forzooming 하려는 대상에 따라서 여러가지 방법으로 구현이 가능함.
    @objc func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        //print("viewFor")
        return imageView
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
    
    private func requestStationName(from stationName: String) {
        let urlString = "http://openapi.seoul.go.kr:8088/sample/json/SearchInfoBySubwayNameService/1/5/\(stationName)"
        
        AF.request(urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "").responseDecodable(of: StationResponseModel.self) { [weak self] response in
            guard
                let self = self,
                case .success(let data) = response.result else { return }
            
            self.stations = data.stations
            self.tableView.reloadData()
        }
        .resume()
    }
    
}

extension StationSearchViewController: UISearchBarDelegate { // 특정 행동의 동작을 위임해주는 프로토콜
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { // 유저가 수정을 시작했을 때 불려짐
        tableView.reloadData()
        tableView.isHidden = false
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { // 유저가 수정을 마쳤을 때 불려짐
        tableView.isHidden = true
        stations = []
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        requestStationName(from: searchText)
    }
}

extension StationSearchViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let station = stations[indexPath.row]
        let vc = StationDetailViewController(station: station)
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension StationSearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        let station = stations[indexPath.row]
        cell.textLabel?.text = station.stationName
        cell.detailTextLabel?.text = station.lineNumber
        
        return cell
    }
}
