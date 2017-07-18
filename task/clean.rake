require "rake/clean"

CLOBBER.include(# Temp stuff
                "tmp",
                # OSX
                ".DS_Store",
                # Build
                "build",
                # Doc
                "doc",
                ".yardoc",
                # Code coverage
                "coverage",
                # Debugging
                ".byebug_history",
                # Stuff specific for `gh-pages-source` branch.
                ".sass-cache",
                ".cache",
                "website",
                "bower_components",
                "helpers",
                "data")
