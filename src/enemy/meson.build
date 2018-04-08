subdir('lib')

enemy_sources = [
          'enemy.cpp'
]

enemy_base = static_library(
                'enemy',
                enemy_sources,
                install: false,
                include_directories: inc,
                link_with: utils
)

subdir('solder')