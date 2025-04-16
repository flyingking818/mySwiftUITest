//
//  ContentView.swift
//  mySwiftUITest
//
//  Created by Jeremy Wang on 4/16/25.
//

import SwiftUI

struct ProfileView: View {
    //@State: A property wrapper that makes a variable mutable and tracks its changes within a view.
    @State private var newComment: String = ""
    @State private var comments: [String] = []
    
    
    var body: some View {
        ZStack{
            Color(UIColor(red: 0.75, green: 0.22, blue: 0.17, alpha: 1))
                .ignoresSafeArea()
            
            VStack (spacing:16){
                Image("Jeremy")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.yellow, lineWidth: 6))
                    .shadow(radius: 8)
                
                Text("Hi Flagler students!")
                    .font(.title2)
                    .bold()
                    .italic()
                    .underline()
                    .foregroundColor(.white)
                
                HStack {
                    Text("Comment:")
                        .foregroundColor(.white)
                    //Binds to newComment, letting users type.
                    TextField("Add your comment!", text: $newComment)
                        .frame(height: 40)
                        .padding(.horizontal)
                        .background(Color.white)
                        .cornerRadius(10)
                }
                .padding(.horizontal)
                
                Button(action: {
                    if !newComment.trimmingCharacters(in: .whitespaces).isEmpty {
                        comments.insert(newComment, at: 0)
                        newComment = ""
                    }
                }) {
                    Text("Post Comment 🎉")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.orange)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Divider().background(Color.white)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(comments, id: \.self) { comment in
                            Text("💬 \(comment)")
                                .padding()
                                .background(Color.white.opacity(0.15))
                                .cornerRadius(10)
                                .foregroundColor(.white)
                        }
                    }
                    .padding()
                }
                
                Spacer()
            }
            .padding()
            
            
            
        }
    }
}

#Preview {
    ProfileView()
}
