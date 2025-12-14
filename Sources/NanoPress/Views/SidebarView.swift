import SwiftUI

struct SidebarView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            List {
                Section(header: Text("Settings")) {
                    VStack(alignment: .leading, spacing: 15) {
                        
                            Label("Compression Level", systemImage: "slider.horizontal.3")
                                .font(.proRounded(.subheadline, weight: .medium))
                            
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
