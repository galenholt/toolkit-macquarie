#' Reader-inner for aggregated Macquarie data
#'
#' @param project_dir outer directory (usually qaelpath/macquarie)
#' @param data_path optional, list or character vector of paths to get data from. If not included, need the searcher terms below
#' @param info_list optional (otherwise need lastagg and retain_cols). list with a name matching aggname, and the lastcol and retain cols in it so it's easier to track
#' @param lastagg name of the last aggregation step, e.g. 'sdl_units'
#' @param retain_cols columns to retain
#' @param data_type search column, historical or stochastic
#' @param mark search, Mark
#' @param licvol search
#' @param climate search
#' @param aggname search, but also references info_list if available. Which aggregation set to pull
#' @param rename_names should match retain_cols
#' @param bind_dfs bind_rows the dfs or return a list of dfs
#' @param max_handling one of 'remove', 'keep1', or 'keep_all' for how to handle the MAX scneario in each dataframe
#'
#' @return
#' @export
#'
#' @examples
read_in_aggs <- function(project_dir,
                         data_path = NULL,
                         info_list = NULL,
                         lastagg,
                         retain_cols,
                         data_type = c('historical', 'stochastic'),
                         mark = 'all',
                         licvol = 'all',
                         climate = 'all',
                         aggname = 'all',
                         rename_names = NULL,
                         bind_dfs = TRUE,
                         max_handling = NULL) {


  if (!is.null(info_list)) {
    if (length(aggname) == 1 && aggname == 'all') {
      aggname <- names(info_list)
    }

    lastagg <- purrr::map_chr(aggname, \(x) info_list[[x]]$lastagg)
    retain_cols <- purrr::map(aggname, \(x) info_list[[x]]$retain) |> unlist()
    rename_names <- purrr::map(aggname, \(x) info_list[[x]]$rename) |> unlist()
  }


  if (is.null(data_path)) {
    data_path <- get_scenariodir(project_dir = project_dir,
                                 data_type = data_type,
                                 mark = mark,
                                 licvol = licvol,
                                 climate = climate,
                                 aggname = aggname)
  }

  fullpaths <- file.path(project_dir, 'aggregated', data_path, 'achievement_aggregated.rds')


  # read in the files
  clean_aggs <- purrr::map(fullpaths, readRDS)

  # should put a test in here that all the retain_cols are actually in the df


  # Clean them up and combine
  clean_aggs <- purrr::map2(clean_aggs, data_path,
                            \(x,y) clean_aggregated(x,
                                                    lastagg = lastagg,
                                                    retain_cols = retain_cols,
                                                    rename_names = rename_names,
                                                    subdir = y))

  if (max_handling == 'remove') {
    maxremove <- 1:length(clean_aggs)
  } else if (max_handling == 'keep1') {
    if (length(clean_aggs) > 1)
    maxremove <- 1:(length(clean_aggs)-1)
  } else if (max_handling == 'keep_all') {
    maxremove <- NULL
  } else {
    if (length(clean_aggs) > 1) {
      rlang::inform(c("Bringing in > 1 dataframe, but not handling max.",
                      "You will have a MAX scenario for each dataframe.",
                      "That might be fine if the dataframes have different possible maxes, but be sure."))
    }
    maxremove <- NULL
  }

  # MAX tends to show up in two places
  if ('scenario' %in% names(clean_aggs[[1]])) {
    clean_aggs[maxremove] <- purrr::map(clean_aggs[maxremove],
                                        \(x) dplyr::filter(x, !grepl('MAX', scenario)))
  } else if ('replicate' %in% names(clean_aggs[[1]])) {
    clean_aggs[maxremove] <- purrr::map(clean_aggs[maxremove],
                                        \(x) dplyr::filter(x, replicate != 'MAX'))
  } else {
    if (!is.null(maxremove)) {
      rlang::warn("No obvious scenario column from which to remove MAX")
    }
  }


  if (bind_dfs) {
    clean_aggs <- clean_aggs |> dplyr::bind_rows()
  }

  return(clean_aggs)

}


select_sequence <- function(aggdata, lastagg, retain_cols) {
  # aggregated columns will always start with the last aggsequence name
  not_aggs <- which(!grepl(paste0('^',
                                  lastagg,
                                  '_'), x = names(aggdata)))

  desired_aggs <- tidyselect::eval_select(retain_cols, aggdata)

  aggdata <- aggdata |>
    dplyr::select(tidyselect::all_of(c(not_aggs, desired_aggs)))


  return(aggdata)
}


clean_aggregated <- function(oneagg, lastagg, retain_cols, rename_names = NULL, subdir) {


  oneagg <- select_sequence(aggdata = oneagg, lastagg, retain_cols)

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

  # some later processing no longer has a scenario column because we've aggregated over parts of the values.
  if ('scenario' %in% names(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(scenario = paste0(subdir, '/', scenario)) |>
      tidyr::separate_wider_delim(scenario, '/',
                                  names = c('Data', 'Mk', 'licvolfactor',
                                            'rem', 'aggregation', 'replicate'),
                                  cols_remove = FALSE) |>
      tidyr::separate_wider_delim(rem, "_e",
                                  names = c("Rainfall","Evapotranspiration")) |>
      dplyr::mutate(across(c(licvolfactor, Rainfall, Evapotranspiration), fix_)) |>
      dplyr::select(scenario, tidyselect::everything())

  }


  # rename the columns
  if (!is.null(rename_names)) {
    oneagg <- oneagg |>
      dplyr::rename_with(.fn = \(x) rename_names, .cols = all_of(retain_cols))
  }

  oneagg <- oneagg |>
    # not sure about this; it's Cudgegong NAs
    dplyr::filter(!is.na(polyID)) |>
    dplyr::relocate(geometry, .after = last_col())

  oneagg <- clean_factors(oneagg)

  return(oneagg)
}

get_scenariodir <- function(project_dir,
                            data_type = c('historical', 'stochastic'),
                            mark = 'all',
                            licvol = 'all',
                            climate = 'all',
                            aggname = 'all') {

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

  return(data_path)
}

clean_factors <- function(oneagg) {
  if ("Mk" %in% colnames(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(
        Mark = dplyr::case_when(
          Mk == "MACQ_CC_EFR_mkva" ~ "Mk5a",
          Mk == "MACQ_CC_EFR_mkv" ~ "Mk5" ,
          Mk == "MACQ_CC_EFR_mkiv" ~ "Mk4a",
          Mk == "MACQ_CC_EFR" ~ "Mk4",
          Mk == NA ~ NA,
          .default = Mk
        )
      )

    oneagg$Mark <-
      factor(oneagg$Mark, levels = c("Mk4", "Mk4a", "Mk5a", "Mk5"))
  }

  if ("Data" %in% colnames(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(
        Data = dplyr::case_when(
          Data == "historical" ~ "Historic",
          Data == "stochastic" ~ "Stochastic",
          .default = Data
        )
      )
  }

  if ("licvolfactor" %in% colnames(oneagg)) {
    if (class(oneagg$licvolfactor) == "character") {
      oneagg <- oneagg |>

        tidyr::separate(licvolfactor, sep = "factor_", remove = TRUE, into = c(NA, "licvolfactor")) |>
        dplyr::mutate(licvolfactor = as.numeric(gsub(x = licvolfactor, pattern = "_", replacement = ".")))
          }
    }

  if ("climate" %in% colnames(oneagg)) {
    if (!"Evapotranspiration" %in% colnames(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(
        Evapotranspiration = dplyr::case_when(
          climate == "r1_0_e1_0" ~ 1.0,
          climate == "r0_8_e1_07" ~ 1.07,
          climate == "r1_0_e1_07" ~ 1.07,
          climate == "r1_2_e1_07" ~ 1.07,
          climate == "r0_8_e1_0" ~ 1.0,
          climate == "r1_2_e1_0" ~ 1.0
        )
      )

    oneagg <- oneagg |>
      dplyr::mutate(
        Rainfall = dplyr::case_when(
          climate == "r1_0_e1_0" ~ 1.0,
          climate == "r0_8_e1_07" ~ 0.8,
          climate == "r1_0_e1_07" ~ 1.0,
          climate == "r1_2_e1_07" ~ 1.2,
          climate == "r0_8_e1_0" ~ 0.8,
          climate == "r1_2_e1_0" ~ 1.2
        )
      )

  }}

  if ("Evapotranspiration" %in% colnames(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(
        names_CSIRO_climate_scenario = dplyr::case_when(
          Evapotranspiration == 1 & Rainfall == 1 ~ "Historical climate",
          Evapotranspiration == 1.07 &
            Rainfall == 0.8  ~ "Hot and Dry",
          Evapotranspiration == 1.07 &
            Rainfall == 1  ~ "Just Hot",
          Evapotranspiration == 1.07 &
            Rainfall == 1.2  ~ "Hot and Wet",
          Evapotranspiration == 1 &
            Rainfall == 0.8  ~ "Just Dry",
          Evapotranspiration == 1 &
            Rainfall == 1.2  ~ "Just Wet"
        )
      )

    oneagg$names_CSIRO_climate_scenario <-
      factor(
        oneagg$names_CSIRO_climate_scenario,
        levels = c(
          "Just Wet",
          "Hot and Wet",
          "Historical climate",
          "Just Hot",
          "Just Dry",
          "Hot and Dry"
        )
      )
  }

  #EWR scale data
  if ("ewr_code" %in% colnames(oneagg)) {
    oneagg$ewr_code <-
      factor(
        oneagg$ewr_code,
        levels = c(
          "CF",
          "VF",
          "BF1",
          "BF2",
          "SF1",
          "SF2",
          "SF3",
          "LF1",
          "LF2",
          "OB-WL",
          "OB-WM",
          "OB-WS1",
          "OB-WS2",
          "OB-WS3",
          "OB-WS4"
        )
      )

    oneagg <- oneagg |>
      dplyr::mutate(
        ewr_group = dplyr::case_when(
          ewr_code == "CF" ~ "CF",
          ewr_code == "VF" ~ "VF",
          ewr_code == "BF1" ~ "BF",
          ewr_code == "BF2" ~ "BF",
          ewr_code == "SF1" ~ "SF",
          ewr_code == "SF2" ~ "SF",
          ewr_code == "SF3" ~ "SF",
          ewr_code == "LF1" ~ "LF",
          ewr_code == "LF2" ~ "LF",
          ewr_code == "OB-WL" ~ "OB",
          ewr_code == "OB-WM" ~ "OB",
          ewr_code == "OB-WS1" ~ "OB",
          ewr_code == "OB-WS2" ~ "OB",
          ewr_code == "OB-WS3" ~ "OB",
          ewr_code == "OB-WS4" ~ "OB",
          .default = ewr_code
        )
      )

    oneagg$ewr_group <-
      factor(oneagg$ewr_group,
             levels = c("CF", "VF", "BF", "SF", "LF", "OB"))

    oneagg <- oneagg |>
      dplyr::mutate(
        ewr_group_name = dplyr::case_when(
          ewr_group == "CF" ~ "Cease to flow",
          ewr_group == "VF" ~ "Very low flow",
          ewr_group == "BF" ~ "Base flow",
          ewr_group == "SF" ~ "Small fresh",
          ewr_group == "LF" ~ "Large fresh",
          ewr_group == "OB" ~ "Overbank",
          .default = ewr_group
        )
      )

    oneagg$ewr_group_name <-
      factor(
        oneagg$ewr_group_name,
        levels = c(
          "Cease to flow",
          "Very low flow",
          "Base flow",
          "Small fresh",
          "Large fresh",
          "Overbank"
        )
      )

  }

  #Target scale data
  if ("target" %in% colnames(oneagg)) {
    oneagg <- oneagg |>
      dplyr::mutate(
        env_group  = dplyr::case_when(
          target == "Native fish" ~ "NF",
          target == "Native vegetation" ~ "NV",
          target == "Other species" ~ "OS",
          target == "Priority ecosystem function" ~ "EF" ,
          target == "Waterbird" ~ "WB",
          target == NA ~ NA,
          .default = target
        )
      )
    oneagg <- oneagg |>
      dplyr::mutate(
        target  = dplyr::case_when(
          target == "Waterbird" ~ "Waterbirds",
          target == NA ~ NA,
          .default = target
        )
      )
  }

  return(oneagg)
}
