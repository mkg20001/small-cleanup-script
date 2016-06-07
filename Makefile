all:
	mv script.sh small-cleanup-script.sh
	shc -f small-cleanup-script.sh -r -v
	mv small-cleanup-script.sh.x small-cleanup-script
test:
	rm -vf script.sh*x*
	shc -f script.sh -r -v
