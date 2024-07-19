# experimental HPC setup script

# I need to make this runnable, right now it just needs to get manually pick and choosed.


## GANDALF
module load R/4.3
# pip on gandalf seems a mess. but supposedly this should work
# (do I need to module load python/3.11? maybe)
conda create -n ewrtool -y && conda activate ewrtool
conda install python=3.11 pandas=2.0.3 numpy -y
# should install the toml, but the direct install seems to work better.
# python3 -m pip install .
pip install py-ewr
# or
# pip install git+https://github.com/MDBAuth/EWR_tool.git@GalenH

# then to use, conda activate ewrtool

# GANDALF 2
# or, it does seem to work to
module load python/3.9
python3 -m venv .venv
source .venv/bin/activate
pip install git+https://github.com/MDBAuth/EWR_tool.git@GalenH

# PETRICHOR
module load R/4.3.1
module load python/3.11.0
# # following https://confluence.csiro.au/display/SC/virtualenv+and+customising+your+python
# source $(which virtualenvwrapper_lazy.sh)
# # pretty sure I really want this
# mkvirtualenv -a <path-to-project-dir> <virtual-env-name>
# # but could use
# mkvirtualenv --system-site-packages <virtual-env-name>
#
# # and then
# workon <virtual-env-name>
# pip install git+https://github.com/MDBAuth/EWR_tool.git@GalenH

# but why not just the venv version?
python3 -m venv .venv
source .venv/bin/activate
pip install git+https://github.com/MDBAuth/EWR_tool.git@GalenH

# ALL
# until the numpy is fixed in the setup.py
pip install --force-reinstall -v "numpy<2.0"

# Either way (assuming the respective module load R has happened)
# We can't use the automated pak method in R_setup.R because it needs sudo.
Rscript "hpc_R.R"
