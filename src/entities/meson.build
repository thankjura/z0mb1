entity = shared_library(
                'entity',
                [
                  'gun_entity.cpp',
                  'main.cpp'
                ],
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                install_rpath: lib_dir,
                link_with: player,
                dependencies: libgodot
)