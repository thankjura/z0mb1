subdir('utils')
subdir('guns')
subdir('player')

player = shared_library(
                'player',
                [],
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_whole: player,
                link_with: [utils, gun],
                install_rpath: lib_dir
)

gun = shared_library(
                'gun',
                [],
                install: true,
                include_directories: inc,
                install_dir: target_dir,
                link_whole: [gun, bullet, bullet_shell],
                link_with: [player]
)

subdir('enemy')