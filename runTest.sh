while true; do
	make run
	inotifywait -e modify  *.hs
done
