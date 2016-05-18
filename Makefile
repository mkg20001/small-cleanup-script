all:
	mv script.sh small-cleanup-script.sh
	shc -f small-cleanup-script.sh -r -v
	mv small-cleanup-script.sh.x small-cleanup-script
