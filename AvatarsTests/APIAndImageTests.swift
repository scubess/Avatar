import XCTest
import Network
import Combine
@testable import Avatars

final class APITests: XCTestCase {

    var sut: NetworkManager!
    private let monitor = NWPathMonitor()
    private var status = NWPath.Status.requiresConnection
    
    private var subscriptions = Set<AnyCancellable>()
    private var users : String!
    private var imageURL : String!
    
    // MARK: - Setup Methods
    override func setUpWithError() throws {
      try super.setUpWithError()
        startNetworkMonitoring()
        sut = NetworkManager.shared
        createEndpoints()
    }
    
    override func tearDownWithError() throws {
      sut = nil
      //stopNetworkMonitoring()
      
      try super.tearDownWithError()
    }

    func createEndpoints() {
        imageURL = Constants.defaultImageURL
        users = Constants.baseURL + Endpoint.users.rawValue
    }
    
    // MARK: - Support Methods
    func startNetworkMonitoring() {
      monitor.pathUpdateHandler = { [weak self] path in
        self?.status = path.status
      }
      let queue = DispatchQueue(label: "NetworkMonitor")
      monitor.start(queue: queue)
    }
    
    func stopNetworkMonitoring() {
      monitor.cancel()
    }
    
    // MARK: - Successfully fetch data from user endpoints
    func testGivenEndpoint_whenMakingApiCall_thenReceiveData() throws {
        
        try XCTSkipUnless(status == .satisfied, "No network available for testing!!")
        
        // given
        let promise = expectation(description: "Data was received!!")

        // when
        sut.FetchData(from: users)
            .sink { completion in
              if case let .failure(error) = completion {
                XCTFail("Error: \(error.localizedDescription)")
              }
            } receiveValue: {
              let _: [GitUser] = $0
              promise.fulfill()
            }
            .store(in: &self.subscriptions)

            wait(for: [promise], timeout: 5)

    }
    
    // MARK: - Successfully download data from and load into a view
    func test_ImageLoadedFromImageDownloader_success() {
        
        let expected = expectation(description: "Image from https did load")
        
        ImageDownloader.loadImageAsync(stringURL: Constants.defaultImageURL) { image, error in
            let viewer = UIImageView(frame: CGRect(x: 0, y: 0, width: 300, height: 250))
            viewer.image = image
            if viewer.image != nil {
                expected.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
    
    // MARK: - Successfully download image from and check the size
    func test_ImageLoadedFromImageDownloader_bytes_success() {
        let expected = expectation(description: "Image from https did load")
        
        ImageDownloader.loadImageAsync(stringURL: Constants.defaultImageURL) { image, error in
            let imgData: NSData = image!.jpegData(compressionQuality: 0)! as NSData
            if imgData.length != 0 {
                expected.fulfill()
            } else {
                XCTFail()
            }
        }
        waitForExpectations(timeout: 3.0, handler: nil)
    }
}
