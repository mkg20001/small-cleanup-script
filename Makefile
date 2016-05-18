all:
	mv script.sh small-cleanup-script.sh
	shc -f small-cleanup-script.sh
	mv small-cleanup-script.sh.x small-cleanup-script
