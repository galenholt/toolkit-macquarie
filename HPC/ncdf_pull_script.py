# script to only pull over what we actually need.
# Should we just move the netcdf cutter here too?

# robocopy to pull this over is in `robocopy scripts.txt`

from py_ewr import data_inputs
import xarray as xr
from glob import glob
import re
import os
import shutil

def check_list(item):
    if not isinstance(item, list):
        raise TypeError(f"Expected a list, but got {type(item).__name__}")

def filter_files(filelist, patternlist):
    # The pattern HAS to be a list or the regex breaks
    check_list(patternlist)
    oschar = re.escape(os.sep)
    # Make the regex for a match between directory markers
    regpat = f'{oschar}|{oschar}'.join(patternlist)
    regpat = f'{oschar}{regpat}{oschar}'
    regpat = re.compile(regpat)
    filelist = [item for item in filelist if regpat.search(item)]
    return(filelist)

def cut_iqqm_ncdf(infile, newpath, newname = 'cut_flows', timeclip = slice(None, None)):
     
    # open the ncdf
    dataset = xr.open_dataset(infile, engine='netcdf4')
    iqqm_dict = data_inputs.get_iqqm_codes()
    # the nodes are ints, but the above is str
    ints_list = list(map(int, list(iqqm_dict)))
    # Get just the nodes that match gauges
    dataset = dataset.sel(node=dataset['node'].isin(ints_list))
    # cut to just flow- this is weirdly roundabout
    availvars = list(dataset.keys())
    availvars.remove('Simulated flow')
    dataset = dataset.drop_vars(availvars)
    # cut the time if timeclip isn't None
    # slice(None, timeclip) # where timeclip = 2000
    dataset = dataset.isel(time = timeclip)
    dataset.to_netcdf(os.path.join(newpath, f"{newname}.nc"))

def cut_all_ncdf(inparent, outparent, hews = ['*'], clims = ['*'], newname = 'cutflows', single_dir = False, timeclip = slice(None, None)):
    # globbing takes a while, so fail early if filter lists are wrong
    check_list(hews)
    check_list(clims)
    # get the tree to all files
    filelist = glob(f"{inparent}/**/*(Gauge).nc", recursive = True)
    # cut to the hew and climate we want
    filelist = filter_files(filelist, hews)
    filelist = filter_files(filelist, clims)
    # get the other files we need too
    tablelist = [item.replace("Straight Node (Gauge).nc", 'h2o_table.nc') for item in filelist]
    csvlist = [item.replace("Straight Node (Gauge).nc", 'total_licvol.csv') for item in filelist]
    # clean up to get the internal tree
    juststruct = [item.replace("Straight Node (Gauge).nc", '') for item in filelist]
    juststruct = [item.replace(inparent, '') for item in juststruct]
    # knock off the starting/ending slashes
    oschar = re.escape(os.sep)
    juststruct = [re.sub(f"^{oschar}|{oschar}$", '', item) for item in juststruct]
    # it should work to just dump everything in one directory as long as the filenames are distinct.
    if single_dir:
        juststruct = [item.replace(os.sep, '_') for item in juststruct]
    newpaths = [os.path.join(outparent, subpath) for subpath in juststruct]
    for directory in newpaths:
        if not os.path.exists(directory):
            os.makedirs(directory)
    for inp, outp, tabp, csvp in zip(filelist, newpaths, tablelist, csvlist):
        cut_iqqm_ncdf(inp, outp, newname, timeclip = timeclip)
        shutil.copy(tabp, os.path.join(outp, "h2o_table.nc"))
        shutil.copy(csvp, os.path.join(outp, "total_licvol.csv"))
    if 'stochastic' in filelist[0]:
        nruns = 76
    else:
        nruns = 1
    expected_files = len(hews)*len(clims)*nruns
    check_expected(outparent, expected_files)

def check_cut(outparent, newname = 'cutflows', return_type = 'number'):
    filelist = glob(f"{outparent}/**/*{newname}.nc", recursive = True)
    if return_type == 'list':
        return(filelist)
    else:
        return(len(filelist))

# I could make this part of cut_all_ncdf, but we probably want to do it manually too
def check_expected(outparent, expected):
    nfiles = check_cut(outparent)
    print(f'Expected {expected} files. Found {nfiles}')

# This lets us use the outer directory, and just change the hews and clims for the marks. And ask for matchign data from stoch and historical
def cut_marks(fromparent, toparent, mark, hews, clims, hs = ['historical', 'stochastic']):
    for i in hs:
        frompath = os.path.join(fromparent, i, mark)
        topath = os.path.join(toparent, i, mark)
        print(frompath)
        print(topath)
        cut_all_ncdf(frompath, topath, hews = hews, clims = clims)


# The paths
basefrom = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\result_jul2024'
baseto= r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\macq_cut'
# If we're calling from petrichor, we can use 
# '/datasets/work/ev-ca-macq/' as the prefix

# Set some common regex patterns
no_mgmt = ['licvolfactor_1_0']
with_mgmt = ['licvolfactor_0_5', 'licvolfactor_0_7', 'licvolfactor_0_9', 'licvolfactor_1_0', 'licvolfactor_1_1', 'licvolfactor_1_3', 'licvolfactor_1_5']
climpattern = ['r0_8_e1_0', 'r0_8_e1_07', 'r1_0_e1_0', 'r1_0_e1_07', 'r1_2_e1_0', 'r1_2_e1_07']

# We could do a big complex thing over the full directory, but since we want different bits from different marks, it'll be cleaner and save time to do the marks separately (and the historic/stochastic)

# Mk4 (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR', hews = no_mgmt, clims = climpattern)
# and manually check too? Probably not needed unless there's a discrepancy
check_expected(os.path.join(baseto, 'stochastic', 'MACQ_CC_EFR'), 6*76)
check_expected(os.path.join(baseto, 'historical', 'MACQ_CC_EFR'), 6)

# Mk4a (7 HEWs * 6 climates * 76 stochastics)
cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkiv', hews = with_mgmt, clims = climpattern)

# Mk5 (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkv', hews = no_mgmt, clims = climpattern)

# Mk5a (Only licvolfactor_1_0), so 6 climate * 76 stochastics = 456
cut_marks(basefrom, baseto, mark = 'MACQ_CC_EFR_mkva', hews = no_mgmt, clims = climpattern)
