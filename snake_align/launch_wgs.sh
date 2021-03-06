#! /bin/bash

ROOT=/proj/ideel/meshnick/users/NickB/Projects/jiffy_salmonella/snake_align # root directory for project (non-scratch)
WD=/pine/scr/n/f/nfb/Projects/jiffy_salmonella/snake_align # working directory for alignments (scratch)
NODES=1028 # max number of cluster nodes
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/align_wgs.snake \
	--configfile config_wgs.yaml \
	--printshellcmds \
	--directory $WD \
	--cluster $ROOT/launch.py \
	-j $NODES \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
	--dryrun -p \
