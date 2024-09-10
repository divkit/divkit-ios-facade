import UIKit

@_implementationOnly import DivKit
@_implementationOnly import VGSL

public enum DivKitFacade {
  public static func createView(
    json: [String: Any],
    localImageProvider: LocalImageProviding? = nil,
    fontProvider: FontProviding? = nil,
    customViewFactory: ContentViewFactory? = nil,
    wrapperConfigurators: [any WrapperViewConfigurator] = [],
    urlHandler: UrlHandling
  ) async -> UIView {
    let imageHolderFactory: DivImageHolderFactory? = if let localImageProvider {
      LocalImageHolderFactory(
        localImageProvider: localImageProvider,
        imageHolderFactory: DefaultImageHolderFactory(
          requestPerformer: URLRequestPerformer(urlTransform: nil)
        )
      )
    } else {
      nil
    }

    let divKitComponents = DivKitComponents(
      divCustomBlockFactory: customViewFactory.map(FacadeCustomBlockFactory.init),
      extensionHandlers: wrapperConfigurators.map(\.extensionHandler),
      fontProvider: fontProvider.map(FontProviderAdapter.init),
      imageHolderFactory: imageHolderFactory,
      urlHandler: UrlHandlerAdapter(handler: urlHandler)
    )

    let divView = await DivView(divKitComponents: divKitComponents)

    guard let card = json["card"] as? [String: Any],
          let divCardId = card["log_id"] as? String else {
      return divView
    }

    await divView.setSource(
      DivViewSource(
        kind: .json(json),
        cardId: DivCardID(rawValue: divCardId)
      )
    )

    let task = Task { @MainActor in
      let root = await VisibilityTrackingRoot()
      root.content = divView
      await root.layoutIfNeeded()
      return root as UIView
    }

    return await task.value
  }
}

private final class VisibilityTrackingRoot: UIView {
  public var content: (VisibleBoundsTracking & UIView)? {
    didSet {
      if window != nil, let oldValue {
        oldValue.onVisibleBoundsChanged(from: oldValue.bounds, to: .zero)
      }
      oldValue?.removeFromSuperview()
      addSubviews(content.asArray())
      setNeedsLayout()
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    guard let content else { return }
    let oldBounds = content.bounds
    content.frame = bounds
    content.onVisibleBoundsChanged(from: oldBounds, to: content.bounds)
  }

  override func didMoveToWindow() {
    super.didMoveToWindow()
    guard let content else { return }

    if window == nil {
      content.onVisibleBoundsChanged(from: content.bounds, to: .zero)
    } else {
      content.onVisibleBoundsChanged(from: .zero, to: content.bounds)
    }
  }
}
