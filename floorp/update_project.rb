require 'xcodeproj'

project_path = 'floorp.xcodeproj'
project = Xcodeproj::Project.open(project_path)
target = project.targets.find { |t| t.name == 'floorp' }

# 1. 物理ファイルが存在する全ファイルをターゲットに登録
Dir.glob('floorp/*.swift').each do |path|
  file_name = File.basename(path)
  # ファイル参照を探す
  file_ref = project.objects.find { |obj| obj.isa == 'PBXFileReference' && obj.name == file_name }
  if file_ref
    unless target.source_build_phase.files_references.include?(file_ref)
      puts "Adding #{file_name} to build phase"
      target.add_file_references([file_ref])
    end
  end
end

# 2. .m ファイルも確実に登録
file_name = 'AppShellDelegate+Floorp.m'
file_ref = project.objects.find { |obj| obj.isa == 'PBXFileReference' && obj.name == file_name }
if file_ref
  unless target.source_build_phase.files_references.include?(file_ref)
    puts "Adding #{file_name} to build phase"
    target.add_file_references([file_ref])
  end
end

project.save
puts "Target Membership updated safely."
