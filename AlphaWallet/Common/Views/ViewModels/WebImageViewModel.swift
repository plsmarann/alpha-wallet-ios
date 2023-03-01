//
//  WebImageViewModel.swift
//  AlphaWallet
//
//  Created by Vladyslav Shepitko on 22.02.2023.
//

import UIKit
import Combine
import AlphaWalletFoundation

//TODO: move later most of logic from app coordinator here
class App {
    let mediaContentDownloader: MediaContentDownloader = {
        let networking = MediaContentNetworkingImpl()
        let cache = KingfisherImageCacheStorage()
        let reachability = ReachabilityManager()

        return MediaContentDownloader(
            networking: networking,
            cache: cache,
            contentResponseInterceptor: GenerateVideoStillInterceptor(cache: cache),
            reachability: reachability)
    }()
    let reachability: ReachabilityManagerProtocol = ReachabilityManager()

    static let shared: App = App()

    private init() { }
}

struct WebImageViewModelInput {
    let loadUrl: AnyPublisher<WebImageViewModel.SetContentEvent, Never>
}

struct WebImageViewModelOutput {
    let viewState: AnyPublisher<WebImageViewModel.ViewState, Never>
    let isPlaceholderHiddenWhenVideoLoaded: AnyPublisher<Bool, Never>
}

class WebImageViewModel {
    private let mediaContentDownloader: MediaContentDownloader
    let avPlayerViewModel: AVPlayerViewModel

    init(mediaContentDownloader: MediaContentDownloader = App.shared.mediaContentDownloader,
         reachability: ReachabilityManagerProtocol = App.shared.reachability) {

        self.mediaContentDownloader = mediaContentDownloader
        self.avPlayerViewModel = .init(reachability: reachability)
    }

    func transform(input: WebImageViewModelInput) -> WebImageViewModelOutput {
        let viewState = input.loadUrl
            .removeDuplicates()
            .flatMapLatest { [mediaContentDownloader] event -> AnyPublisher<WebImageViewModel.ViewState, Never> in
                switch event {
                case .image(let image):
                    guard let image = image else { return .just(.noContent) }

                    return .just(.content(.image(image)))
                case .url(let url):
                    guard let url = url else { return .just(.noContent) }

                    return mediaContentDownloader.fetch(url)
                        .map { state -> WebImageViewModel.ViewState in
                            switch state {
                            case .loading: return .loading
                            case .done(let value): return ViewState.content(value)
                            //Not applicatable here, as publisher returns can failure, handled in `replaceError`
                            case .failure: return .noContent
                            }
                        }.replaceError(with: .noContent)
                        .eraseToAnyPublisher()
                case .cancel:
                    return .just(.noContent)
                }
            }.eraseToAnyPublisher()

        let isPlaceholderHiddenWhenVideoLoaded = viewState.filter {
            switch $0 {
            case .content(let content):
                switch content {
                case .video: return true
                case .image, .svg: return false
                }
            case .loading, .noContent: return false
            }
        }.flatMap { [avPlayerViewModel] _ in avPlayerViewModel.viewState }
        .compactMap { viewState -> Bool? in
            switch viewState {
            case .loading: return nil
            case .done(let mediaType): return mediaType == .video //NOTE: hide placeholder only when failure or loaded content type is video, skip when loading
            case .failure: return false
            }
        }.eraseToAnyPublisher()

        return .init(viewState: viewState, isPlaceholderHiddenWhenVideoLoaded: isPlaceholderHiddenWhenVideoLoaded)
    }
}

extension WebImageViewModel {
    enum SetContentEvent: Equatable {
        case url(URL?)
        case image(UIImage?)
        case cancel
    }

    enum ViewState: CustomStringConvertible {
        case noContent
        case loading
        case content(MediaContentDownloader.Content)

        var description: String {
            switch self {
            case .loading:
                return "ViewState.loading"
            case .noContent:
                return "ViewState.emptyContent"
            case .content(let data):
                switch data {
                case .image:
                    return "ViewState.image"
                case .video:
                    return "ViewState.video"
                case .svg:
                    return "ViewState.svg"
                }
            }
        }
    }
}
