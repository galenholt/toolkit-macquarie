# File to make sure I'm getting the resources I need/think I'm getting

# What's the question here: If I give it a list of paths 4,000 long, I don't want 4,000 separate jobs, I want to break that up into nested things with multicore over the cores in teh nodes
# according to the docs, all petrichor nodes have 64 CPUs, and most have 512GB RAM. 

library(dplyr)
library(tibble)
library(doFuture)
library(future.batchtools)
library(furrr)

# A version with `workers` declared, rather than the default 100
# So, this should use 5 nodes, each of which has 10 tasks. If i give it something of length 50 the nodes should each get used once, tasks once. If 100, approcimately twixe and once
plan(list(tweak(batchtools_slurm,
                workers = 2,
                template = "HPC/batchtools.slurm.tmpl",
                resources = list(time = 4,
                                 ntasks.per.node = 8, 
                                 mem = 1000,
                                 job.name = 'NewName')),
          multicore))

cat("\n Plan is:\n")

plan("list")

# Instead of nesting an inner and outer, with defined inner/outer matchign the
# list-plan, we want to just feed it a single long list and see if it uses the
# right number of nodes and cores
all_par <- function(looplist) {
  inner_out <- foreach(j = looplist,
                       .combine = bind_rows) %dofuture% {
                         thisproc <- tibble(all_job_nodes = paste(Sys.getenv("SLURM_JOB_NODELIST"),
                                                                  collapse = ","),
                                            node = Sys.getenv("SLURMD_NODENAME"), 
                                            nworkers = nbrOfWorkers(),                                           
                                            iteration = j, 
                                            pid = Sys.getpid(),
                                            taskid = Sys.getenv("SLURM_LOCALID"),
                                            jobid = Sys.getenv("SLURM_JOB_ID"),
                                            cpus_avail = Sys.getenv("SLURM_JOB_CPUS_PER_NODE")) 
                         
                       }
  return(inner_out)
}

# What do we see for resources *before* we call anything?
cat('\n### available workers:\n')
cat(availableWorkers(), sep = "\n")
cat('\n\n### total workers:\n')
cat(length(availableWorkers()))
cat('\n\n### unique workers:\n')
cat(unique(availableWorkers()))



cat('\n\n### available Cores:\n')
cat("\n#### non-slurm\n")
cat(availableCores(), sep = "\n")
cat("\n#### slurm method\n")
cat(availableCores(methods = 'Slurm'), sep = "\n")

# base R process id
cat('\n### Main PID:\n')
cat(Sys.getpid(), sep = "\n")


# LOOP --------------------------------------------------------------------

looper <- 1:(4*2*2)
looptib <- all_par(looper)

# OUTPUT ------------------------------------------------------------------



cat('\n### Unique nodes\n')
cat(length(unique(looptib$node)))
# cat("\n\nIDs of all nodes used\n\n")
# cat(unique(looptib$outer_pid), sep = "\n")

cat('\n### Number of workers assigned to each node\n')
cat(length(unique(looptib$nworkers)))

cat('\n### Unique cores\n')
cat(length(unique(looptib$inner_pid)))
cat("\n\nIDs of all cores used\n\n")
cat(unique(looptib$inner_pid), sep = "\n")

cat('\n## Nodes and pids simple\n')
looptib %>% 
  group_by(node) %>% 
  summarise(n_inner = n_distinct(inner_pid)) %>% 
  print(n = Inf)
cat("\n")

cat('\n## Each PID could get used for multiple jobs potentially\n')
looptib %>% 
  group_by(node, inner_pid) %>% 
  summarise(n_reps = n()) %>% 
  print(n = Inf)
cat("\n")

cat("\n## Nodes and PIDS more info\n")
looptib %>% 
  group_by(all_job_nodes, node, taskid, cpus_avail) %>% 
  summarize(n_reps = n(),
            n_inner = n_distinct(inner_pid)) %>% 
  print(n = Inf)
cat("\n")

# So, that doesn't seem to work. But what if we did somethign like this?

# The cores per node just gts dealt with by slurm, there's no way to do that here, I don't tink
outerwrap <- function(fulloop, nodes_wanted) {
    # Split into things to send to the nodes
    nodeloops <- split(fulloop, cut(1:length(fulloop), nodes_wanted, labels = FALSE))

    outer_out <- foreach(j = nodeloops,
                       .combine = bind_rows) %dofuture% {
                         all_par(j)
                       }
  return(outer_out)
}

doubletib <- outerwrap(looper, 2)

doubletib

# That does work. The catch is, the list to loop over gets found *inside* the function, so extracting it a priori will be annoying.
# I suppose I could just go for it with one call per list item, but it will default to workers = 100. And if I make it workers = Inf, the IT people will kill me.
# It'll also mean we have a separate yaml per file instead of all together. Though maybe I'll have to sit in the queue shorter if I only ask for one cpu? Not sure how much more overhead there is to spin up nodes vs cpuss

# But I actually use furrr- does it behave the same?
make_tib <- function(j) {
thisproc <- tibble(all_job_nodes = paste(Sys.getenv("SLURM_JOB_NODELIST"),
                            collapse = ","),
    node = Sys.getenv("SLURMD_NODENAME"), 
    nworkers = nbrOfWorkers(),                                           
    iteration = j, 
    pid = Sys.getpid(),
    taskid = Sys.getenv("SLURM_LOCALID"),
    jobid = Sys.getenv("SLURM_JOB_ID"),
    cpus_avail = Sys.getenv("SLURM_JOB_CPUS_PER_NODE"))
return(thisproc)
}

# The single
loopfur <- furrr::future_map(looper, make_tib, .options = furrr::furrr_options(seed = TRUE)) |> bind_rows()
# Yeah, still only one pid per node.s
loopfur_s <- furrr::future_map(looper, make_tib, .options = furrr::furrr_options(seed = TRUE, scheduling = 8)) |> bind_rows()
# That actually looks like it might have worked? I get 8 PIDs per node. I need to see what the queue looks like I think.
# Nope, it's calling a new job for each pid. so that's not good.
loopfur_s |> summarise(pid = unique(pid), .by = node)

loopfur_c <- furrr::future_map(looper, make_tib, .options = furrr::furrr_options(seed = TRUE, chunk_size = 8)) |> bind_rows()
# That *doesn't* work. I did look at the queue though and it only called two jobs. 

# nested

innerfurfun <- function(looper) {
    furrr::future_map(looper, make_tib, .options = furrr::furrr_options(seed = TRUE)) |> bind_rows()
}

nestfur <- function(fulloop, nodes_wanted) {
    nodeloops <- split(fulloop, cut(1:length(fulloop), nodes_wanted, labels = FALSE))
    infur <- furrr::future_map(nodeloops, innerfurfun, .options = furrr::furrr_options(seed = TRUE)) |> bind_rows()
    return(infur)

}

nestedfurtib <- nestfur(looper, 2)
nestedfurtib

nl <- split(looper, cut(1:length(looper), 2, labels = FALSE))
nestedoneline <- furrr::future_map(nl, \(x) furrr::future_map(x, make_tib, .options = furrr::furrr_options(seed = TRUE)) |> bind_rows(), .options = furrr::furrr_options(seed = TRUE)) |> bind_rows()

# so, the seemingly only way to get this to have cores inside nodes (which is what we want, to minimize queueing and jobs), is to nest. 
# I could do that manually (looping over sets of hydro_paths, well, I think I'd have to get the full set of files and pass each in as a hydro_dir. No, that won't work either, I need a parent folder that has ~ 64 files inside). So maybe index into the climates and send each of them to a node? Would need to be clever with output_subdirs. but it will stuff up the hydro paths. I think. Maybe it wouldn't be too bad if I just got directories and ended up with a yaml each? 
# Could test that with the cut.
# OR, I could modify prep_run_save_ewrs to take nesting arguments and nest the safe_imap. That seems very specific, but would work.

# So, one option is manual and directory-aware but easy to stuff up, and the other is automatic but requires changing prep_run_save_ewrs
# Either way, I need to do some speed tests for single runs, and calculate the multis.
# and see if I can run from sinteractive.

# I think the way to go is the manual diretory-based way. read_and_agg does a recursive search, so we should be OK.s

# basically, O should be able to get hydro_paths as a list of something after I cut down list.dirs('/datasets/work/ev-ca-macq/work/hol436/ash_cut', recursive = TRUE) 
# To just the climate level. and for historical. Then loop over that.
# and for everything, list.dirs('/datasets/work/ev-ca-macq/work/hol436/hydrographs', recursive = TRUE). The regex will suck, but should be doable.
