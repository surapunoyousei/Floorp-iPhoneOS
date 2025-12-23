require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

project.targets.each do |target|
  target.build_configurations.each do |config|
    s = config.build_settings
    
    # 全てのパスを、プロジェクトからの相対パスで明示
    if target.name == 'floorp'
      s['CODE_SIGN_ENTITLEMENTS'] = 'floorp/floorp.entitlements'
    elsif ['WebContent', 'Networking', 'Rendering'].include?(target.name)
      s['CODE_SIGN_ENTITLEMENTS'] = "floorp/#{target.name}.entitlements"
    end
    
    # 署名フラグを強制
    s['OTHER_CODE_SIGN_FLAGS'] = '--deep --force'
    s['AD_HOC_CODE_SIGNING_ALLOWED'] = 'YES'
  end
end

project.save
puts "Target entitlements synchronized with precision."
