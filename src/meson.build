subdir('utils')
subdir('guns')
subdir('player')

player = shared_library(
                'player',
                [],
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_whole: player_static,
                link_with: [utils, gun_static],
                install_rpath: lib_dir,
                dependencies: libgodot
)

gun = shared_library(
                'gun',
                [],
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_whole: [gun_static, bullet, bullet_shell],
                link_with: [player, utils],
                install_rpath: lib_dir,
                dependencies: libgodot
)

subdir('enemy')