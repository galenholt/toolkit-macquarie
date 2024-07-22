# agg-reading and retention variables.

# sdl_ewr_timeseries
retained_sEt <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_ewr_achieved')

# sdl_target_timeseries
retained_sTt <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_ewr_achieved')

# sdl_ewr_spells
retained_sEs <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                  'sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                  'sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years')

# sdl_target_spells
retained_sTs <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                  'sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                  'sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years')

# sdl_ewr_vulnerability
retained_vE <- c('replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Max_sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years')

# sdl_target_vulnerability
retained_vT <- c('replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Max_sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years')

aggregation_info <- list(sdl_ewr_timeseries = list(lastagg = 'sdl_units',
                                                   retained = retained_sEt),
                         sdl_target_timeseries = list(lastagg = 'sdl_units',
                                                      retained = retained_sTt),
                         sdl_ewr_spells = list(lastagg = 'sdl_units',
                                               retained = retained_sEs),
                         sdl_target_spells = list(lastagg = 'sdl_units',
                                                  retained = retained_sTs),
                         sdl_ewr_vulnerability = list(lastagg = 'replicates',
                                                      retained = retained_vE),
                         sdl_target_vulnerability = list(lastagg = 'replicates',
                                                         retained = retained_vT))
