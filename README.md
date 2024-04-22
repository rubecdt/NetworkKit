# NetworkKit

NetworkKit is a modular and efficient Swift networking library that provides enhanced `URLSession` functionalities, request deduplication, structured API interactions, and built-in support for JSON and image handling. The package is designed to be used in Swift applications requiring a flexible and performant network layer.

## Features

- **Network Request Deduplication**: Avoids redundant network requests using `URLSessionCoalescer`.
- **Custom URL Request Hashing**: Implements `URLRequest.HashingStrategy` for flexible request uniqueness.
- **Modular Design**: Organized into submodules:
  - `NetworkCore`: Core networking utilities.
  - `NetworkImages`: Image downloading and caching.
  - `NetworkJSON`: JSON request and decoding utilities.
- **Mocking & Testing Support**: Provides `URLMockResponder` for testing network calls.

## Installation

### Swift Package Manager (SPM)

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/rubecdt/NetworkKit.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "YourApp", dependencies: ["NetworkKit"])
    ]
)
```

## Usage

### Basic Request with NetworkInteractor

```swift
import NetworkKit

struct APIClient: NetworkInteractor {
    let session = URLSession.shared
}

let apiClient = APIClient()
let url = URL(string: "https://api.example.com/data")!

Task {
    do {
        let data = try await apiClient.fetch(for: URLRequest(url: url))
        print("Received Data: \(data)")
    } catch {
        print("Request failed: \(error)")
    }
}
```

### Request Deduplication with `URLSessionCoalescer`

```swift
let coalescer = URLSessionCoalescer<URLRequest.NetworkKitHashing>()
let request = URLRequest(url: url)

Task {
    let data = try await coalescer.fetch(for: request)
    print("Deduplicated Request Data: \(data)")
}
```

### JSON Decoding with `NetworkJSONInteractor`

```swift
struct APIClient: NetworkJSONInteractor {
    let session = URLSession.shared
}

let jsonClient = APIClient()

Task {
    struct ResponseData: Decodable {
        let message: String
    }
    let decodedResponse: ResponseData = try await jsonClient.fetchJSON(for: URLRequest(url: url))
    print("Message: \(decodedResponse.message)")
}
```

### Image Downloading with `NetworkImageInteractor`

```swift
struct ImageClient: NetworkImageInteractor {
    let session = URLSession.shared
}

let imageClient = ImageClient()

Task {
    let image = try await imageClient.fetchImage(from: url)
    print("Image downloaded: \(image)")
}
```

## Testing

SFSB-NetworkKit includes built-in network mocking capabilities.

```swift
import Testing
import NetworkMocks

@Suite("Network Tests")
struct NetworkTests {
    @Test("Mocked Response")
    func mockTest() async throws {
        let responder = URLStaticMockResponder.succeeding(with: (Data(), HTTPURLResponse()))
        let session = URLSession.mock(responder: responder)
        let apiClient = APIClient(session: session)

        let data = try await apiClient.fetch(for: URLRequest.sample)
        #expect(data.isEmpty)
    }
}
```

## License

NetworkKit is available under the MIT license. See the LICENSE file for more details.

