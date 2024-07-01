# script to only pull over what we actually need.
# Should we just move the netcdf cutter here too?

# robocopy to pull this over is in `robocopy scripts.txt`

from cut_iqqm_ncdf import cut_all_ncdf # doesn't seem to work and all sorts of weird indendtation errors. Just copy-paste those functions (inst/python/cut_iqqm_ncdf.py) over to CSIRO

# Historic
outerpath = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\ewater_experiments\historical'

newpath = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\ash_cut\historical'

cut_all_ncdf(outerpath, newpath)

# Mk4 (Only licvolfactor_1_0), so 7 climate * 76 stochastics = 532
mk4from = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\ewater_experiments\stochastic\MACQ_CC_EFR\licvolfactor_1_0'
mk4to = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\ash_cut\stochastic\MACQ_CC_EFR\licvolfactor_1_0'
cut_all_ncdf(mk4from, mk4to)

# Mk4a (everything)MACQ_CC_EFR_mkiv (7 licvol, 7 climate, 76 stochastic = 3724)
mk4afrom = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\ewater_experiments\stochastic\MACQ_CC_EFR_mkiv'
mk4ato = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\ash_cut\stochastic\MACQ_CC_EFR_mkiv'
cut_all_ncdf(mk4afrom, mk4ato)

# Mk5 (Only licvolfactor_1_0), so 7 climate * 76 stochastics = 532
mk5from = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\ewater_experiments\stochastic\MACQ_CC_EFR_mkv\licvolfactor_1_0'
mk5to = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\ash_cut\stochastic\MACQ_CC_EFR_mkv\licvolfactor_1_0'
cut_all_ncdf(mk5from, mk5to)

# Mk5a (Only licvolfactor_1_0), so 7 climate * 76 stochastics = 532
mk5afrom = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\sho108\werp\results\ewater_experiments\stochastic\MACQ_CC_EFR_mkva\licvolfactor_1_0'
mk5ato = r'\\fs1-cbr.nexus.csiro.au\{ev-ca-macq}\work\hol436\ash_cut\stochastic\MACQ_CC_EFR_mkva\licvolfactor_1_0'
cut_all_ncdf(mk5afrom, mk5ato)


# and I also need to harvest those other files Georgia needed
