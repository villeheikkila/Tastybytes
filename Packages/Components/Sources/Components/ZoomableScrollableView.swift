import SwiftUI

public struct ZoomableScrollableView<Content: View>: View {
    @ViewBuilder let content: Content

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }

    public var body: some View {
        ZoomableScrollableUIViewRepresentable {
            content
        }
    }
}

private struct ZoomableScrollableUIViewRepresentable<Content: View>: UIViewRepresentable {
    @ViewBuilder let content: Content
    @State private var currentScale: CGFloat = 1.0
    @State private var tapLocation: CGPoint = .zero

    public func makeUIView(context: Context) -> UIScrollView {
        let scrollView = UIScrollView()
        scrollView.backgroundColor = .clear
        scrollView.delegate = context.coordinator
        scrollView.maximumZoomScale = 4.0
        scrollView.minimumZoomScale = 1
        scrollView.bouncesZoom = true
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.clipsToBounds = false

        let hostedView = context.coordinator.hostingController.view!
        hostedView.translatesAutoresizingMaskIntoConstraints = true
        hostedView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        hostedView.frame = scrollView.bounds
        hostedView.backgroundColor = .clear
        scrollView.addSubview(hostedView)

        let doubleTapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleDoubleTap(_:)))
        doubleTapGesture.numberOfTapsRequired = 2
        scrollView.addGestureRecognizer(doubleTapGesture)

        return scrollView
    }

    public func makeCoordinator() -> Coordinator {
        Coordinator(hostingController: UIHostingController(rootView: content), scale: $currentScale)
    }

    public func updateUIView(_ uiView: UIScrollView, context: Context) {
        context.coordinator.hostingController.rootView = content

        if uiView.zoomScale > uiView.minimumZoomScale {
            uiView.setZoomScale(currentScale, animated: true)
        } else if tapLocation != .zero {
            uiView.zoom(to: zoomRect(for: uiView, scale: uiView.maximumZoomScale, center: tapLocation), animated: true)
            DispatchQueue.main.async { tapLocation = .zero }
        }
    }

    private func zoomRect(for scrollView: UIScrollView, scale: CGFloat, center: CGPoint) -> CGRect {
        let scrollViewSize = scrollView.bounds.size

        let width = scrollViewSize.width / scale
        let height = scrollViewSize.height / scale
        let x = center.x - (width / 2.0)
        let y = center.y - (height / 2.0)

        return CGRect(x: x, y: y, width: width, height: height)
    }

    public class Coordinator: NSObject, UIScrollViewDelegate {
        var hostingController: UIHostingController<Content>
        @Binding var currentScale: CGFloat

        init(hostingController: UIHostingController<Content>, scale: Binding<CGFloat>) {
            self.hostingController = hostingController
            _currentScale = scale
        }

        public func viewForZooming(in _: UIScrollView) -> UIView? {
            hostingController.view
        }

        public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with _: UIView?, atScale scale: CGFloat) {
            currentScale = scale
            centerContent(in: scrollView)
        }

        private func centerContent(in scrollView: UIScrollView) {
            guard let contentView = scrollView.subviews.first else { return }

            let boundsSize = scrollView.bounds.size
            var contentFrame = contentView.frame

            if contentFrame.size.width < boundsSize.width {
                contentFrame.origin.x = (boundsSize.width - contentFrame.size.width) / 2
            } else {
                contentFrame.origin.x = 0
            }

            if contentFrame.size.height < boundsSize.height {
                contentFrame.origin.y = (boundsSize.height - contentFrame.size.height) / 2
            } else {
                contentFrame.origin.y = 0
            }

            contentView.frame = contentFrame
        }

        @objc func handleDoubleTap(_ gesture: UITapGestureRecognizer) {
            guard let scrollView = gesture.view as? UIScrollView else { return }

            if scrollView.zoomScale > scrollView.minimumZoomScale {
                scrollView.setZoomScale(scrollView.minimumZoomScale, animated: true)
            } else {
                let location = gesture.location(in: scrollView)
                let zoomRect = zoomRectForScale(scrollView.maximumZoomScale, withCenter: location, in: scrollView)
                scrollView.zoom(to: zoomRect, animated: true)
            }
        }

        private func zoomRectForScale(_ scale: CGFloat, withCenter center: CGPoint, in scrollView: UIScrollView) -> CGRect {
            var zoomRect = CGRect.zero
            zoomRect.size.width = scrollView.frame.size.width / scale
            zoomRect.size.height = scrollView.frame.size.height / scale
            zoomRect.origin.x = center.x - (zoomRect.size.width / 2.0)
            zoomRect.origin.y = center.y - (zoomRect.size.height / 2.0)
            return zoomRect
        }
    }
}
