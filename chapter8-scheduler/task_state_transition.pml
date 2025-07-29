inline putQ(task) {
	readyQ!!change[task].pri,task
}

// This process handles status transitions and queueing of tasks.
active proctype TaskStateTransition() {
	mtype:TransitionEvents event;byte task;
	
	do 
	:: atomic{toStateM?event(task) -> 
			if 
			:: (change[task].state == passive) && (event == release) -> 
				change[task].state = ready;
				putQ(task)
			:: (change[task].state == ready) && (event == choose) -> change[task].state = running;
			:: (change[task].state == running) && (event == yield) -> 
				if 
				:: (change[task].togo > 0) -> 
					change[task].state = ready;
					putQ(task)
				:: else -> change[task].state = passive;
				fi
			:: (change[task].state == running) && (event == wait) -> 
				change[task].state = blocked;
				atomic{printf("Task %d is blocked. togo++\n",task);
				change[task].togo = change[task].togo + 1;}
			:: (change[task].state == blocked) && (event == notify) -> 
				if 
				:: (change[task].togo > 0) -> 
					change[task].state = ready;
					putQ(task)
				:: else -> assert(false);change[task].state = passive;
				fi
			:: else -> skip;
			fi
		}
	od
}
