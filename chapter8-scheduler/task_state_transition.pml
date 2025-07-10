inline putQ(i) {
	readyQ!!change[i].pri,i
}

proctype TaskStateTransition() {
	mtype:TransitionEvent M;short I;

	do 
	:: atomic{toStateM?M,I} -> 
		if 
		:: (change[I].state == passive) && (M == release) -> change[I].state = ready;putQ(I)
		:: (change[I].state == ready) && (M == choose) -> change[I].state = running;
		:: (change[I].state == running) && (M == yield) -> 
			if 
			:: (change[I].togo > 0) -> change[I].state = ready;putQ(I)
			:: else -> change[I].state = passive;
			fi
		:: (change[I].state == running) && (M == wait) -> change[I].state = blocked;change[I].togo = change[I].togo + 1;
		:: (change[I].state == blocked) && (M == notify) -> 
			if 
			:: (change[I].togo > 0) -> change[I].state = ready;putQ(I)
			:: else -> change[I].state = passive;
			fi
		:: else -> skip;
		fi
	od
}


