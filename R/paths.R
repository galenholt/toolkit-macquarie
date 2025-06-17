# Sets paths

if (Sys.info()['user'] == 'galen') {
  qaelpath <- '~/../Deakin University/QAEL - WERP in house - WERP'
} else if (Sys.info()['user'] == 'Georgiad') {
  qaelpath <- '~/Deakin University/QAEL - WERP - WERP'
} else if (Sys.info()['user'] == 'georgiad') {
  qaelpath <- 'C:/Users/georgiad/Deakin University/QAEL - WERP - WERP'
} else if (Sys.info()['user'] == 'Admin') {
  qaelpath <- 'C:/Users/Admin/Deakin University/QAEL - WERP in house - WERP'
} else if (Sys.info()['user'] == 'hol436') { # PETRICHOR
  qaelpath <- ''
} else {
  rlang::abort("YOU'RE NOT A RECOGNISED USER. PUT IN YOUR PATH TO PROJECT")
}

# python can't use the tildes, so have to expand
qaelpath <- path.expand(qaelpath)


if (Sys.info()['user'] == 'hol436') {
  project_dir <- file.path('/datasets/work/ev-ca-macq/work/hol436')
} else {
  project_dir <- file.path(qaelpath, 'Toolkit', 'macquarie')
}

data_path <- file.path(project_dir, "hydrographs")

ewr_results <- file.path(project_dir, 'module_output', 'EWR', 'hydrographs')

agg_dir <- file.path(project_dir, 'aggregated')
hydro_results <- file.path(project_dir, "module_output", "Hydrology")
Economic_results <- file.path(project_dir, "module_output", "Economic")

comp_results <- file.path(project_dir, "comparer_output")

Called_Targets_path <- file.path(project_dir, "delivery_strategies", "Targets.csv")
Called_Orders_path <- file.path(project_dir, "delivery_strategies", "Orders.csv")
Called_Orders2_path <- file.path(project_dir, "delivery_strategies", "Orders2.csv")
