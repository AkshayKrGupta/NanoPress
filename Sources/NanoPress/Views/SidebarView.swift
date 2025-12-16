//
//  SidebarView.swift
//  NanoPress
//
//  Created by Akshay Kumar Gupta on 16/12/25.
//  Copyright © 2025 Akshay Kumar Gupta. All rights reserved.
//

import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Settings")) {
                    VStack(alignment: .leading, spacing: 15) {
                        
                            Label("Image Compression Level", systemImage: "slider.horizontal.3")
                                .font(.proRounded(.subheadline, weight: .medium))
                            
                            // Preset Buttons
                            HStack(spacing: 8) {
                                PresetButton(title: "Low", subtitle: "50%", value: 0.5, 
                                           currentValue: $viewModel.compressor.compressionQuality)
                                PresetButton(title: "Medium", subtitle: "75%", value: 0.75, 
                                           currentValue: $viewModel.compressor.compressionQuality)
                                PresetButton(title: "High", subtitle: "90%", value: 0.9, 
                                           currentValue: $viewModel.compressor.compressionQuality)
                            }
                            
                            Text("Custom")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .padding(.top, 4)
                            
                            VStack(spacing: 8) {
                                Slider(value: $viewModel.compressor.compressionQuality, in: 0.0...1.0)
                                    .tint(.accentColor)
                                
                                HStack {
                                    Text("Low")
                                    Spacer()
                                    Text("\(Int(viewModel.compressor.compressionQuality * 100))%")
                                        .bold()
                                    Spacer()
                                    Text("High")
                                }
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            }
                        

                    }
                    .padding(.vertical, 8)
                }

                Divider()
                .padding(.bottom, 8)
                
                Section(header: Text("PDF Settings")) {
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Compression Mode", systemImage: "doc.text.fill")
                            .font(.proRounded(.subheadline, weight: .medium))
                        
                        Picker("", selection: $viewModel.compressor.pdfCompressionMode) {
                            ForEach(PDFCompressionMode.allCases) { mode in
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(mode.rawValue)
                                        .font(.body)
                                    Text(mode.description)
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                        .lineLimit(2)
                                        .multilineTextAlignment(.leading)
                                        .fixedSize(horizontal: false, vertical: true)
                                }
                                .tag(mode)
                            }
                        }
                        .pickerStyle(.radioGroup)
                        .labelsHidden()
                    }
                    .padding(.vertical, 8)
                }
                
                Section(header: Text("Appearance")) {
                    HStack {
                        ForEach(AppTheme.allCases) { theme in
                            Button(action: { viewModel.selectedTheme = theme }) {
                                Image(systemName: viewModel.themeIcon(for: theme))
                                    .frame(width: 20, height: 20)
                            }
                            .buttonStyle(.bordered)
                            .tint(viewModel.selectedTheme == theme ? .accentColor : .secondary)
                        }
                    }
                }
            }
            .listStyle(.sidebar)
            
            // Footer Section
            SidebarFooterView()
        }
    }
}
