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
                Section(header: 
                    Text("Settings")
                        .font(.sectionHeader(size: 22))
                        .foregroundStyle(NanoDesign.accentGradient)
                ) {
                    VStack(alignment: .leading, spacing: NanoDesign.Spacing.lg) {
                        
                            Label("Image Compression Level", systemImage: "slider.horizontal.3")
                                .font(.bodyMedium)
                                .symbolRenderingMode(.hierarchical)
                            
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
                                .font(.secondaryText(size: 11))
                                .foregroundStyle(.secondary)
                                .padding(.top, NanoDesign.Spacing.xs)
                            
                            VStack(spacing: NanoDesign.Spacing.sm) {
                                Slider(value: $viewModel.compressor.compressionQuality, in: 0.0...1.0)
                                    .tint(.accentColor)
                                
                                HStack {
                                    Text("Low")
                                    Spacer()
                                    Text("\(Int(viewModel.compressor.compressionQuality * 100))%")
                                        .fontWeight(.semibold)
                                    Spacer()
                                    Text("High")
                                }
                                .font(.secondaryText(size: 10))
                                .foregroundStyle(.secondary)
                            }
                        

                    }
                    .padding(.vertical, NanoDesign.Spacing.sm)
                }

                Divider()
                .padding(.bottom, NanoDesign.Spacing.sm)
                
/*                 Section(header: 
                    Text("PDF Settings")
                        .font(.sectionHeader(size: 22))
                        .foregroundStyle(NanoDesign.accentGradient)
                )  */
                Section {
                    VStack(alignment: .leading, spacing: NanoDesign.Spacing.md) {
                        Label("PDF Compression Mode", systemImage: "doc.text.fill")
                            .font(.bodyMedium)
                            .symbolRenderingMode(.hierarchical)
                        
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
                    .padding(.vertical, NanoDesign.Spacing.sm)
                }
                
                Section(header: 
                    Text("Appearance")
                        .font(.sectionHeader(size: 22))
                        .foregroundStyle(NanoDesign.accentGradient)
                ) {
                    HStack(spacing: NanoDesign.Spacing.sm) {
                        ForEach(AppTheme.allCases) { theme in
                            Button(action: { 
                                withAnimation(.selectionSpring) {
                                    viewModel.selectedTheme = theme 
                                }
                            }) {
                                Image(systemName: viewModel.themeIcon(for: theme))
                                    .uiIconStyle()
                                    .frame(width: 24, height: 24)
                            }
                            .buttonStyle(.bordered)
                            .tint(viewModel.selectedTheme == theme ? .accentColor : .secondary)
                            .scaleEffect(viewModel.selectedTheme == theme ? 1.05 : 1.0)
                            .animation(.selectionSpring, value: viewModel.selectedTheme)
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
