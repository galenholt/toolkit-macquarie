# R setup for HPC

# This bit is needed for HPCs, where we need to have already hassled the owner
# to install the C dependencies, or it stuffs up the install because of sf etc

# This path stuff should be handled by .Rprofile on startup
# renvpaths <- .libPaths()
# .libPaths(new = c(renvpaths,'/ceph-g/opt/R/4.3/lib/R/library' ))
# Sys.setenv('R_LIBS' = '/ceph-g/opt/R/4.3/lib/R/library')

# Gandalf
# module load R/4.3
# Petrichor
# module load R/4.3.1

# We can't use the automated pak method in R_setup.R because it needs sudo.
# The issue here is this tries to upgrade sf, but we can't. I tried upgrade = 'never', and that faild too
# I tried with 'remotes' directly, and it also failed. Maybe it would work on Gandalf
renv::install('git@github.com:galenholt/HydroBOT.git',
              rebuild = TRUE, upgrade = 'always', git = 'external', prompt = FALSE)

# the soluton on petrichor seems to be to clone it locally and edit DESCRIPTION
# to remove sf and lwgeom, at least for the moment. It's a terrible workaround,
# but should work if we don't do anything spatial. That means we will have to
# move to local for the aggregator
renv::install('../HydroBOT')
# git2r also needs C. And some of this is just dev, which we wouldn't do on an HPC
renv::install(c('ggthemes',
                'knitr',
                'patchwork',
                # 'rmapshaper (>= 0.4.6)',
                'colorspace',
                'rmarkdown',
                'scico',
                # 'testthat (>= 3.0.0)',
                # 'vdiffr',
                # 'withr',
                # 'git2r', # not available on gandalf, already on petrichor
                'jsonlite',
                'foreach',
                'furrr',
                'future',
                'DiagrammeRsvg',
                # 'rsvg',
                'metR',
                'PCICt',
                # 'ncdf4', # needed on gandalf, already on petrichor but older
                'lubridate'))

deps <- unique(renv::dependencies()$Package)
pkgavail <- dimnames(installed.packages())[[1]]

not_installed <- deps[!deps %in% pkgavail]

if (length(not_installed) > 0) {
  message(paste0("These packages are not installed: ", not_installed,
                 '.\nThey are in the object `not_installed`, so first thing to try is `renv::install(not_installed)`\n',
                 'sf may need admin help due to C libraries\n',
                 'CC2 and other github packages seem to need to be handled manually'))
}

# install py-ewr through R?
# reticulate::py_install('git+https://github.com/MDBAuth/EWR_tool.git@GalenH')
