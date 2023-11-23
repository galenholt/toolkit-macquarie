# I don't think the renv install is necessary-it should auto-install since there's a project skeleton
# install.packages('renv')

# use pak to handle system dependencies on linux
if (grepl("unix", .Platform$OS.type)) {
    install.packages('pak', repos = sprintf('https://r-lib.github.io/p/pak/stable/%s/%s/%s', .Platform['pkgType'], R.Version()['os'], R.Version()['arch']))
    renv::install('yaml')
    deps <- renv::dependencies()
    depchars <- c(deps$Package, 'scico', 'ggthemes', 'furrr')
    depchars <- depchars[depchars != 'R']
    depchars <- depchars[depchars != 'werptoolkitr']
    depchars <- unique(depchars)
    sysdeps <- pak::pkg_sysreqs(depchars)

    # build and run those
    system2(command = 'sudo', args = sysdeps$pre_install)
    system2(command = 'sudo', args = sysdeps$install_scripts)
    if (length(sysdeps$post_install) > 0) {
        system2(command = 'sudo', args = sysdeps$post_install)
    }

    # Should work, but doesn't always. I think because it only fixes *installed* packages, and renv won't install if they fail
    # pak::sysreqs_fix_installed(depchars)
}

# install R packages
# renv without {remotes} will only install from main. So if we want to use a branch, we need to go with remotes directly
renv::install('remotes')
# First, the newest version of the toolkit - it doesn't always find updates or deal with caching correctly from git hashes
remotes::install_git('git@github.com:MDBAuth/WERP_toolkit.git', ref = 'galen_working', force = TRUE, upgrade = 'ask', git = 'external', rebuild = TRUE)
# Everything else
renv::install()
renv::install(c('scico', 'ggthemes', 'furrr'))

#
# # To give the user a set of hydrographs to look at
# dir.create(file.path('template_data', 'hydrographs'), recursive = TRUE)
# toolhydro <- list.files(system.file('extdata/testsmall/hydrographs', package = 'werptoolkitr'), full.names = TRUE)
# file.copy(toolhydro, to = file.path('template_data', 'hydrographs'), recursive = TRUE)
