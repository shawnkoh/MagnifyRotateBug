//
//  ContentView.swift
//  SwiftUIBug
//
//  Created by Shawn Koh on 31/8/21.
//

import SwiftUI

struct ContentView: View {
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1

    @State var angle = Angle()
    @State var finalAngle = Angle()

    var body: some View {
        // Credit: https://stackoverflow.com/a/58468234/8639572
        let magnificationGesture = MagnificationGesture()
            .onChanged { scaleDelta in
                print("magnify on changed", scaleDelta)
                let delta = scaleDelta / self.lastScale
                self.lastScale = scaleDelta
                let newScale = self.scale * delta
                self.scale = (WorldViewModel.minScale ... WorldViewModel.maxScale).clamp(newScale)
            }
            .onEnded { scaleDelta in
                print("magnify on ended", scaleDelta)
                self.lastScale = 1
            }

        // Credit: https://www.hackingwithswift.com/books/ios-swiftui/how-to-use-gestures-in-swiftui
        let rotationGesture = RotationGesture()
            .onChanged { angle in
                print("rotate on changed", angle.degrees)
                self.angle = angle
            }
            .onEnded { angle in
                print("rotate on ended", angle.degrees)
                self.finalAngle += self.angle
                self.angle = .degrees(0)
            }

        let magnificationAndRotationGesture = magnificationGesture.simultaneously(with: rotationGesture)

        Rectangle()
            .foregroundColor(.white)
            .frame(width: UIScreen.screenHeight, height: UIScreen.screenHeight)
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            .scaleEffect(scale)
            .rotationEffect(angle + finalAngle)
            .gesture(magnificationAndRotationGesture)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension UIScreen {
    static let screenSize = UIScreen.main.bounds.size
    static let screenWidth = screenSize.width
    static let screenHeight = screenSize.height
}

enum WorldViewModel {
    static let minScale: CGFloat = CGFloat(430) / CGFloat(1024)
    static let maxScale: CGFloat = CGFloat(4096) / CGFloat(1024)
}

extension CGSize {
    static func + (lhs: Self, rhs: Self) -> CGSize {
        .init(width: lhs.width + rhs.width, height: lhs.height + rhs.height)
    }

    static func += (lhs: inout Self, rhs: Self) {
        lhs = lhs + rhs
    }
}

extension ClosedRange {
    func clamp(_ value: Bound) -> Bound {
        self.lowerBound > value ? self.lowerBound
            : self.upperBound < value ? self.upperBound
            : value
    }
}
