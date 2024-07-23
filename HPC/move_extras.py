
# Moved the below to its own file so the functions are more useful.
exec(open('HPC/cut_pull_funs.py').read())
#

# The paths
# basefrom = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\result_jul2024'
# baseto= r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\macq_cut'
# If we're calling from petrichor, we can use 
# '/datasets/work/ev-ca-macq/' as the prefix
basefrom = '/datasets/work/ev-ca-macq/work/sho108/werp/results/result_jul2024'
baseto = '/datasets/work/ev-ca-macq/work/hol436/macq_cut'

# Set some common regex patterns
no_mgmt = ['licvolfactor_1_0']
with_mgmt = ['licvolfactor_0_5', 'licvolfactor_0_7', 'licvolfactor_0_9', 'licvolfactor_1_0', 'licvolfactor_1_1', 'licvolfactor_1_3', 'licvolfactor_1_5']
climpattern = ['r0_8_e1_0', 'r0_8_e1_07', 'r1_0_e1_0', 'r1_0_e1_07', 'r1_2_e1_0', 'r1_2_e1_07']

# We could do a big complex thing over the full directory, but since we want different bits from different marks, it'll be cleaner and save time to do the marks separately (and the historic/stochastic)

all_extrafiles = ['h2o_table.nc', 'total_licvol.csv', 'allocation_reliability.csv', 'allocation_resilience.csv', 'hs_delivered_to_ordered_ratio_reliability.csv', 'hs_delivered_to_ordered_ratio_resilience.csv']

extrafiles = ['hs_delivered_to_ordered_ratio_reliability.csv']

# Test 
# cut_marks(basefrom, baseto, hews = no_mgmt, mark = 'MACQ_CC_EFR', clims = ['r0_8_e1_0'], extrafiles = extrafiles, cutncs = False)
# DON'T JUST DO EVERYTHING; there are WAY more scenarios than we want.
cut_marks(fromparent = basefrom, toparent = baseto, mark = 'MACQ_CC_EFR', hews = no_mgmt, clims = climpattern, extrafiles = extrafiles, cutncs = False)
cut_marks(fromparent = basefrom, toparent = baseto, mark = 'MACQ_CC_EFR_mkiv', hews = with_mgmt, clims = climpattern, extrafiles = extrafiles, cutncs = False)
cut_marks(fromparent = basefrom, toparent = baseto, mark = 'MACQ_CC_EFR_mkv', hews = no_mgmt, clims = climpattern, extrafiles = extrafiles, cutncs = False)
cut_marks(fromparent = basefrom, toparent = baseto, mark = 'MACQ_CC_EFR_mkva', hews = no_mgmt, clims = climpattern, extrafiles = extrafiles, cutncs = False)



# # Mk4 (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
# cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR', hews = no_mgmt, clims = climpattern)
# # and manually check too? Probably not needed unless there's a discrepancy
# check_expected(os.path.join(baseto, 'stochastic', 'MACQ_CC_EFR'), 6*76)
# check_expected(os.path.join(baseto, 'historical', 'MACQ_CC_EFR'), 6)

# # Mk4a (7 HEWs * 6 climates * 76 stochastics)
# cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkiv', hews = with_mgmt, clims = climpattern)

# # Mk5 (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
# cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkv', hews = no_mgmt, clims = climpattern)

# # Mk5a (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
# cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkva', hews = no_mgmt, clims = climpattern)
