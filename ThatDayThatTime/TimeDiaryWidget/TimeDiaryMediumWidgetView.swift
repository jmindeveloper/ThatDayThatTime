//
//  TimeDiaryMediumWidgetView.swift
//  TimeDiaryWidgetExtension
//
//  Created by J_Min on 7/3/24.
//

import SwiftUI

struct TimeDiaryMediumWidgetView: View {
    @State var diary: DiaryEntity
    
    var body: some View {
        VStack {
            HStack {
                Text((diary.date ?? "") + " " + (diary.time ?? ""))
                    .foregroundColor(.black)
                    .font(.system(size: 11, weight: .semibold))
                Spacer()
            }
            
            GeometryReader { proxy in
                HStack {
                    if let image = diary.image {
//                        
                        SwiftUI.Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: proxy.size.height, height: proxy.size.height)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .padding(.trailing, 3)
                    }
                    
                    VStack(alignment: .leading) {
                        Spacer()
                        Text("시간의 기록")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .padding(.bottom, 1)
                        
                        Text(diary.content ?? "")
                            .foregroundColor(.black)
                            .lineLimit(3)
                            .font(.system(size: 13))
                        
                        Spacer()
                    }
                }
            }
        }
        .padding()
    }
}
