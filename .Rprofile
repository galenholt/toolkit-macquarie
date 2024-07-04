source("renv/activate.R")

options(repos = c(PPM = "https://packagemanager.posit.co/cran/latest",
CRAN = "https://packagemanager.posit.co/cran/latest",
RSPM = "https://packagemanager.posit.co/cran/latest"))

# Need to set libpaths here for future to see them
if (grepl('^petrichor', Sys.info()["nodename"]) | grepl('^c', Sys.info()["nodename"])) {
  renvpaths <- .libPaths()
  .libPaths(new = c(renvpaths,"/apps/R/4.3.1/lib64/R/library" ))
} else if (grepl('^gandalf', Sys.info()["nodename"])) {
  renvpaths <- .libPaths()
  .libPaths(new = c(renvpaths,'/ceph-g/opt/R/4.3/lib/R/library' ))
}

# we only need to use pak on unix
# if (grepl("unix", .Platform$OS.type)) {
#     options(renv.config.pak.enabled = TRUE)
# }

