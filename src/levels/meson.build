subdir('intro')
subdir('objects')

level_sources = [
  'level.cpp',
  'main.cpp'
]

level_lib = shared_library(
                'level',
                level_sources,
                install: true,
                include_directories: inc,
                link_with:[
                  level_objects,
                  level_intro,
                  player
                ],
                install_dir: target_dir,
                install_rpath: lib_dir,
                dependencies: libgodot
)