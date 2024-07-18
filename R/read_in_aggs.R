read_in_aggs <- function(project_dir,
                         data_path = NULL,
                            data_type = c('historical', 'stochastic'),
                            mark = 'all',
                            licvol = 'all',
                            climate = 'all',
                            aggname = 'all',
                            lastagg,
                            retain_cols) {


  # construct requested data paths if not given explicitly
  if (is.null(data_path)) {
    # assume only one project_dir

    # keep working on this stuff as the aggs run.

    # get the data type dirs
    if (length(data_type) == 1 && data_type == 'all') {
      data_path <- list.dirs(file.path(project_dir, 'aggregated'),
                             recursive = FALSE, full.names = FALSE) |>
        as.list()
    } else {
      data_path <- data_type |> as.list()
    }

    # file.path does not build factorially, so have to do it manually

    # add mark level
    if (length(mark) == 1 && mark == 'all') {
      mark_list <- purrr::map(data_path, \(x) list.dirs(file.path(project_dir, 'aggregated', x),
                                                        recursive = FALSE, full.names = FALSE))
    } else {
      mark_list <- rep(list(mark), length(data_path))
    }

    # easiest way to go will be joining at each point
    data_path <- purrr::map2(data_path, mark_list, file.path) |>
      unlist()

    # add licvol level
    if (length(licvol) == 1 && licvol == 'all') {
      licvol_list <- purrr::map(data_path, \(x) list.dirs(file.path(project_dir, 'aggregated', x),
                                                          recursive = FALSE, full.names = FALSE))
    } else {
      licvol_list <- rep(list(licvol), length(data_path))
    }

    data_path <- purrr::map2(data_path, licvol_list, file.path) |>
      unlist()

    # add climate level
    if (length(climate) == 1 && climate == 'all') {
      climate_list <- purrr::map(data_path, \(x) list.dirs(file.path(project_dir, 'aggregated', x),
                                                           recursive = FALSE, full.names = FALSE))
    } else {
      climate_list <- rep(list(climate), length(data_path))
    }

    data_path <- purrr::map2(data_path, climate_list, file.path) |>
      unlist()

    # add aggname level
    if (length(aggname) == 1 && aggname == 'all') {
      aggname_list <- purrr::map(data_path, \(x) list.dirs(file.path(project_dir, 'aggregated', x),
                                                           recursive = FALSE, full.names = FALSE))
    } else {
      aggname_list <- rep(list(aggname), length(data_path))
    }

    data_path <- purrr::map2(data_path, aggname_list, file.path) |> unlist()

  }


  paths_to_files <- file.path(project_dir, 'aggregated', data_path, 'achievement_aggregated.rds')



  clean_aggs <- purrr::map(paths_to_files, readRDS)

  # should put a test in here that all the retain_cols are actually in the df


  # overwrite to save memory
  clean_aggs <- purrr::map2(clean_aggs, data_path,
                            \(x,y) clean_aggregated(x,
                                                    lastagg = lastagg,
                                                    retain_cols = retain_cols,
                                                    subdir = y)) |>
    dplyr::bind_rows()

  return(clean_aggs)

}


clean_aggregated <- function(oneagg, lastagg, retain_cols, subdir) {

  # aggregated columns will always start with the last aggsequence name
  not_aggs <- which(!grepl(paste0('^',
                                  lastagg,
                                  '_'), x = names(oneagg)))

  desired_aggs <- tidyselect::eval_select(retain_cols, oneagg)

  oneagg <- oneagg |>
    dplyr::select(tidyselect::all_of(c(not_aggs, desired_aggs)))

  # If we keep MAX, will need to be careful on read-in of multiple agg files not to duplicate it.

  # Make scenarios unique
  # I *hate* using path separators / in this, but if I use _ like I want, it'll get confused with Ash's use to sub them with . in things like 1_07.

  # I should parse here too into the cols to actually ID them
  fix_ <- function(x) {
    x <- gsub('[A-Za-z]*', '', x)
    x <- gsub('^_', '', x)
    x <- gsub('_', '.', x)
    x <- as.numeric(x)
  }

  oneagg <- oneagg |>
    dplyr::mutate(scenario = paste0(subdir, '/', scenario)) |>
    tidyr::separate_wider_delim(scenario, '/',
                                names = c('Data', 'Mk', 'licvolfactor',
                                          'rem', 'aggregation', 'stoch_replicate'),
                                cols_remove = FALSE) |>
    tidyr::separate_wider_delim(rem, "_e",
                                names = c("Rainfall","Evapotranspiration")) |>
    dplyr::mutate(across(c(licvolfactor, Rainfall, Evapotranspiration), fix_)) |>
    # not sure about this; it's Cudgegong NAs
    dplyr::filter(!is.na(polyID)) |>
    dplyr::select(scenario, tidyselect::everything()) |>
    dplyr::relocate(geometry, .after = last_col())

  return(oneagg)
}
