//
//  EndDetectionScrollView.swift
//  Xplorify
//
//  Created by Mohsen on 11/18/24.
//

import SwiftUI

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = .zero
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {}
}

struct EndDetectionScrollView<Content: View>: View {
    let axis: Axis.Set
    let showIndicators: Bool
    @Binding var hasScrolledToEnd: Bool
    let content: () -> Content
    
    @State private var visibleContentHeight: CGFloat = 0
    @State private var totalContentHeight: CGFloat = 0
    
    init(_ axis: Axis.Set,
         showIndicators: Bool,
         hasScrolledToEnd: Binding<Bool>,
         @ViewBuilder content: @escaping () -> Content) {
        self.content = content
        self.axis = axis
        self.showIndicators = showIndicators
        self._hasScrolledToEnd = hasScrolledToEnd
    }
    
    var body: some View {
        ScrollView(axis, showsIndicators: showIndicators) {
            offsetReader
            content()
                .overlay(content:  {
                    GeometryReader(content: { geometry in
                        Color.clear.onAppear {
                            self.totalContentHeight = geometry.frame(in: .global).height
                        }
                    })
                })
                
        }
        .overlay(content:  {
            GeometryReader(content: { geometry in
                Color.clear.onAppear {
                    self.visibleContentHeight = geometry.frame(in: .global).height
                }
            })
        })
        .coordinateSpace(name: "frameLayer")
        .onPreferenceChange(OffsetPreferenceKey.self, perform: { offset in
            if totalContentHeight < visibleContentHeight {
                hasScrolledToEnd = false
                return
            }
            if totalContentHeight != 0 && visibleContentHeight != 0 {
                if (totalContentHeight - visibleContentHeight) + offset <= 0 {
                    hasScrolledToEnd = true
                } else {
                    hasScrolledToEnd = false
                }
            } else {
                hasScrolledToEnd = false
            }
        })
    }
    
    var offsetReader: some View {
        GeometryReader { proxy in
            Color.clear
                .preference(
                    key: OffsetPreferenceKey.self,
                    value: proxy.frame(in: .named("frameLayer")).maxY
                )
        }
        .frame(height: 0)
    }
}
