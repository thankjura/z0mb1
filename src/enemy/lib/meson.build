enemy_bullet_sources = [
  'bullet.cpp',
  'change_direction.cpp',
  'main.cpp'
]

enemy = shared_library(
                'enemy',
                enemy_bullet_sources,
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                install_rpath: lib_dir,
                link_with: player,
                dependencies: libgodot
)