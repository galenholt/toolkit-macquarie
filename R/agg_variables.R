# sdl_ewr_timeseries
retained_sEt <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_ewr_achieved')

rename_sEt <- 'ewr_achieved'

# sdl_target_timeseries
retained_sTt <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_ewr_achieved')

rename_sTt <- 'ewr_achieved'

# sdl_ewr_spells
retained_sEs <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                  'sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                  'sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years')

rename_sEs <- c('ewr_achieved',
                'mean_max_interevent',
                'max_interevent')

# sdl_target_spells
retained_sTs <- c('sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                  'sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                  'sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years')

rename_sTs <- c('ewr_achieved',
                'mean_max_interevent',
                'max_interevent')

# sdl_ewr_vulnerability
retained_vE <- c('replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Max_sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_Max_planning_units_Max_ewr_code_Max_all_time_maxInterevent_event_years')

rename_vE <- c('ewr_achieved',
               'mean_max_interevent',
               'max_interevent',
               'variance_ewr_achieved',
               'variance_mean_max_interevent',
               'variance_max_interevent')

# sdl_target_vulnerability
retained_vT <- c('replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_ArithmeticMean_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Max_sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_ArithmeticMean_ewr_achieved',
                 'replicates_Variance_sdl_units_ArithmeticMean_planning_units_ArithmeticMean_target_ArithmeticMean_ewr_code_ArithmeticMean_all_time_maxInterevent_event_years',
                 'replicates_Variance_sdl_units_Max_planning_units_Max_target_Max_ewr_code_Max_all_time_maxInterevent_event_years')

rename_vT <- c('ewr_achieved',
               'mean_max_interevent',
               'max_interevent',
               'variance_ewr_achieved',
               'variance_mean_max_interevent',
               'variance_max_interevent')


# Make the list -----------------------------------------------------------


aggregation_info <- list(sdl_ewr_timeseries = list(lastagg = 'sdl_units',
                                                   retained = retained_sEt,
                                                   renames = rename_sEt),
                         sdl_target_timeseries = list(lastagg = 'sdl_units',
                                                      retained = retained_sTt,
                                                      renames = rename_sTt),
                         sdl_ewr_spells = list(lastagg = 'sdl_units',
                                               retained = retained_sEs,
                                               renames = rename_sEs),
                         sdl_target_spells = list(lastagg = 'sdl_units',
                                                  retained = retained_sTs,
                                                  renames = rename_sTs),
                         sdl_ewr_vulnerability = list(lastagg = 'replicates',
                                                      retained = retained_vE,
                                                      renames = rename_vE),
                         sdl_target_vulnerability = list(lastagg = 'replicates',
                                                         retained = retained_vT,
                                                         renames = rename_vT))
