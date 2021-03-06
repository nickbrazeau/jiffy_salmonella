#! /bin/bash

ROOT=/proj/ideel/meshnick/users/NickB/Projects/jiffy_salmonella/snake_varcall
WD=/pine/scr/n/f/nfb/Projects/jiffy_salmonella/vcfs_gatk_joint_raw/
NODES=1028 # max number of cluster nodes
WAIT=30 # number of seconds to wait for files to appear, absorbing some file system latency

snakemake \
	--snakefile $ROOT/call_gatk4.snake \
	--configfile $ROOT/config.yaml \
	--printshellcmds \
	--directory $WD \
	--cluster $ROOT/launch.py \
	-j $NODES \
	--rerun-incomplete \
	--keep-going \
	--latency-wait $WAIT \
	--dryrun -p
