sources = [
          'animation.cpp',
          'camera.cpp',
          'audio.cpp',
          'movement.cpp',
          'input.cpp',
          'player.cpp'
]

player = shared_library(
                'player',
                sources,
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_with: [utils, gun],
                install_rpath: lib_dir
)