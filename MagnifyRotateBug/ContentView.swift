//
//  ContentView.swift
//  SwiftUIBug
//
//  Created by Shawn Koh on 31/8/21.
//

import SwiftUI

// Hello!
// The main bug occurs when you repeatedly pinch in / out on the white rectangle.
// SwiftUI will eventually fail - that is, you are no longer able to rotate and magnify the view.
// Furthermore, other SwiftUI native components like a Picker stops becoming interactable.
// However, you can still modify, and even animate, the value of the Picker by clicking on the Button.

// This bug is also replicable without the Picker and the Button.

// If you need any further clarifications please feel free to email me at shawn(at)shawnkoh(dot)sg
// I am also readily contactable on Telegram at shawnkohzq

struct ContentView: View {
    @State var scale: CGFloat = 1
    @State var lastScale: CGFloat = 1

    @State var angle = Angle()
    @State var finalAngle = Angle()

    // Optional. Bug is still replicable if you remove this.
    @State var selection: Size = .size1

    var body: some View {
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
            .scaleEffect(scale)
            .rotationEffect(angle + finalAngle)
            .gesture(magnificationAndRotationGesture)
            .frame(minWidth: .zero, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
            // Optional. Bug is still replicable if you remove this.
            // The purpose of the Picker is to demonstrate the Picker UI freezing.
            .overlay(
                Picker("Test", selection: $selection) {
                    ForEach((0 ..< Size.allCases.count).reversed(), id: \.self) { index in
                        let size = Size.allCases[index]

                        Circle()
                            .foregroundColor(.red)
                            .frame(width: 30, height: 30)
                            .tag(size)
                    }
                }
                .frame(width: 50)
                , alignment: .leading
            )
            // Optional. Bug is still replicable if you remove this.
            .overlay(
                Button {
                    withAnimation {
                        selection = Size(rawValue: Int.random(in: 1...5)) ?? .size1
                    }
                } label: {
                    Text("Set Random Selection")
                }
                ,alignment: .trailing
            )
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

enum Size: Int, CaseIterable, Equatable {
    case size1 = 1, size2, size3, size4, size5
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
