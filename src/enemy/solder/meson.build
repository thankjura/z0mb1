solder_sources = [
  'animation.cpp',
  'solder.cpp',
  'main.cpp'
]

enemy_solder = shared_library(
                'solder',
                solder_sources,
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_whole: enemy,
                link_with: [player],
                install_rpath: lib_dir
)