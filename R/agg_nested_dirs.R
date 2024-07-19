read_aggregated <- function(project_dir,
                            data_type = c('historical', 'stochastic'),
                            mark = 'all',
                            licvol = 'all',
                            climate = 'all',
                            aggname = 'all',
                            lastagg,
                            retain_cols) {


  # assume only one project_dir

  # keep working on this stuff as the aggs run.

  # # get the data type dirs
  # if (length(data_type) == 1 && data_type == 'all') {
  #   data_path <- list.dirs(file.path(project_dir, 'aggregated', data_type), recursive = FALSE, full.names = FALSE)
  # } else {
  #   data_path <- data_type
  # }
  #
  # # file.path does not build factorially, so have to do it manually
  #
  # markpath <- foreach(d = data_path, .combine = c) %do% {
  #   if (length(mark) == 1 && mark == 'all') {
  #     mark_path <- list.dirs(d, recursive = FALSE, full.names = FALSE)
  #   } else {
  #     mark_path <- mark
  #   }
  # }
  #




  subdir <- file.path(data_type, mark, licvol, climate)
  paths_to_files <- file.path(project_dir, 'aggregated', subdir, aggname, 'achievement_aggregated.rds')



  clean_aggs <- purrr::map(paths_to_files, readRDS) |>
    dplyr::bind_rows()

  # should put a test in here that all the retain_cols are actually in the df


  # overwrite to save memory
  clean_aggs <- clean_aggregated(clean_aggs, lastagg = lastagg, retain_cols = retain_cols, subdir = subdir)

  return(clean_aggs)
  # savepath <- file.path(project_dir,
  #                       'aggregated',
  #                       subdir)
  #
  # # Save the list and process it, rather than directly save it out
  # oneagg <- read_and_agg(
  #   datpath = file.path(ewr_dir, subdir),
  #   type = "achievement",
  #   geopath = bom_basin_gauges,
  #   causalpath = causal_list,
  #   groupers = "scenario",
  #   aggCols = aggCols,
  #   aggsequence = aggsequence,
  #   funsequence = funsequence,
  #   keepAllPolys = FALSE,
  #   auto_ewr_PU = TRUE,
  #   saveintermediate = FALSE,
  #   returnList = TRUE,
  #   savepath = file.path(savepath, aggname)
  # )

  # # aggregated columns will always start with the last aggsequence name
  # not_aggs <- which(!grepl(paste0('^',
  #                                 names(aggsequence)[length(aggsequence)],
  #                                 '_'), x = names(oneagg)))
  #
  # desired_aggs <- tidyselect::eval_select(retain_cols, oneagg)
  #
  # oneagg <- oneagg |>
  #   dplyr::select(tidyselect::all_of(c(not_aggs, desired_aggs)))
  #
  # # If we keep MAX, will need to be careful on read-in of multiple agg files not to duplicate it.
  #
  # # Make scenarios unique
  # # I *hate* using path separators / in this, but if I use _ like I want, it'll get confused with Ash's use to sub them with . in things like 1_07.
  #
  # # I should parse here too into the cols to actually ID them
  # fix_ <- function(x) {
  #   x <- gsub('[A-Za-z]*', '', x)
  #   x <- gsub('^_', '', x)
  #   x <- gsub('_', '.', x)
  #   x <- as.numeric(x)
  # }
  #
  # oneagg <- oneagg |>
  #   dplyr::mutate(scenario = paste0(subdir, '/', scenario)) |>
  #   tidyr::separate_wider_delim(scenario, '/',
  #                               names = c('Data', 'Mk', 'licvolfactor',
  #                                         'rem', 'stoch_replicate'),
  #                               cols_remove = FALSE) |>
  #   tidyr::separate_wider_delim(rem, "_e",
  #                               names = c("Rainfall","Evapotranspiration")) |>
  #   dplyr::mutate(across(c(licvolfactor, Rainfall, Evapotranspiration), fix_)) |>
  #   # not sure about this; it's Cudgegong NAs
  #   dplyr::filter(!is.na(polyID)) |>
  #   dplyr::select(scenario, tidyselect::everything(), geometry)
  #
  #
  # savepath <- file.path(project_dir,
  #                       'aggregated',
  #                       subdir)
  #
  # if (!dir.exists(savepath)) {
  #   dir.create(savepath, recursive = TRUE)
  # }
  # saveRDS(oneagg,
  #         file = file.path(savepath,
  #                          paste0(aggname, '.rds')))

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
                                          'rem', 'stoch_replicate'),
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
