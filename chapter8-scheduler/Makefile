pan.c: scheduler.pml
	spin -a $<

pan: pan.c
	gcc -O3 -o $@ $<

run: pan
	rm -f *.trail
	./pan -a -n -m30000

trail:
	clear
	spin -t -p scheduler.pml

clean:
	rm -f pan.* *.trail pan *.tmp
