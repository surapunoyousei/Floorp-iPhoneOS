require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# 全ターゲットを取得
all_targets = project.targets

# 共通で使用すべき Swift ファイルのリスト
common_files = [
  'AllowOrDeny.swift',
  'ContentDelegate.swift',
  'EventDispatcher.swift',
  'GeckoRuntime.swift',
  'GeckoSession.swift',
  'GeckoSessionHandler.swift',
  'GeckoView.swift',
  'NavigationDelegate.swift',
  'PermissionDelegate.swift',
  'ProgressDelegate.swift'
]

# プロジェクト内のファイル参照を全スキャンして紐付け
common_files.each do |file_name|
  file_ref = project.objects.find { |obj| obj.isa == 'PBXFileReference' && obj.name == file_name }
  if file_ref
    all_targets.each do |target|
      # まだターゲットに含まれていなければ追加
      unless target.source_build_phase.files_references.include?(file_ref)
        puts "Forcing linkage: #{file_name} -> #{target.name}"
        target.add_file_references([file_ref])
      end
    end
  else
    puts "Warning: Could not find file reference for #{file_name}"
  end
end

project.save
puts "Surgical linkage of common files complete."
