#!/usr/bin/env ruby

# This script fixes the build phase order in Xcode to prevent dependency cycles
# with Widget Extensions

require 'xcodeproj'

project_path = 'Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find the Runner target
runner_target = project.targets.find { |t| t.name == 'Runner' }

if runner_target.nil?
  puts "❌ Could not find Runner target"
  exit 1
end

puts "✅ Found Runner target"

# Get build phases
embed_frameworks_phase = runner_target.shell_script_build_phases.find { |phase| 
  phase.name == '[CP] Embed Pods Frameworks' 
}

thin_binary_phase = runner_target.shell_script_build_phases.find { |phase| 
  phase.name == 'Thin Binary' 
}

copy_resources_phase = runner_target.shell_script_build_phases.find { |phase| 
  phase.name == '[CP] Copy Pods Resources' 
}

embed_extensions_phase = runner_target.copy_files_build_phases.find { |phase|
  phase.name == 'Embed Foundation Extensions' || 
  phase.name == 'Embed App Extensions' ||
  phase.dst_subfolder_spec == :plug_ins
}

if embed_extensions_phase.nil?
  puts "⚠️  No Embed Extensions phase found - this is OK if Widget Extension target exists"
else
  puts "✅ Found Embed Extensions phase"
  
  # Move Embed Extensions to the end
  runner_target.build_phases.delete(embed_extensions_phase)
  runner_target.build_phases << embed_extensions_phase
  
  puts "✅ Moved Embed Extensions phase to the end"
end

# Ensure proper order: Resources -> Frameworks -> Thin Binary -> Embed Extensions
phases_to_reorder = []
phases_to_reorder << copy_resources_phase if copy_resources_phase
phases_to_reorder << embed_frameworks_phase if embed_frameworks_phase
phases_to_reorder << thin_binary_phase if thin_binary_phase
phases_to_reorder << embed_extensions_phase if embed_extensions_phase

# Remove all these phases and re-add in correct order
phases_to_reorder.compact.each do |phase|
  runner_target.build_phases.delete(phase)
end

# Re-add in correct order (before other phases)
compile_sources_index = runner_target.build_phases.index { |p| p.is_a?(Xcodeproj::Project::Object::PBXSourcesBuildPhase) }
insert_index = compile_sources_index ? compile_sources_index + 1 : runner_target.build_phases.count

phases_to_reorder.compact.reverse.each do |phase|
  runner_target.build_phases.insert(insert_index, phase)
end

# Save project
project.save

puts "✅ Successfully reordered build phases to prevent dependency cycle"
puts ""
puts "Build phase order:"
runner_target.build_phases.each_with_index do |phase, index|
  puts "  #{index + 1}. #{phase.display_name}"
end
