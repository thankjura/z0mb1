project('z0mb1','cpp',
  version: '0.1.0',
  meson_version: '>= 0.40.0',
)


config_h = configuration_data()

configure_file(
  output: 'test-config.h',
  configuration: config_h,
)

inc = include_directories(
  '/home/GrandMaster/Development/games/godot-engine/modules/gdnative/include',
  '/home/GrandMaster/Development/games/godot-cpp/include',
  '/home/GrandMaster/Development/games/godot-cpp/include/gen'
)

add_project_arguments([
  '-I' + meson.build_root(),
  '-std=c++14',
  '-fpermissive',
  '-O2',
  '-ggdb',
], language: 'cpp')

add_project_link_arguments([
  '-std=c++14',
  '-fpermissive',
  '-L/home/GrandMaster/Development/games/godot-cpp/bin/',
  '-lgodot-cpp'
], language : 'cpp')

lib_dir = 'lib64'
target_dir = meson.source_root() + '/' + lib_dir

subdir('src')
