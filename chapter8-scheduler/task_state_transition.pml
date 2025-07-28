inline putQ(task) {
	readyQ!!change[task].pri,task
}

// タスクの状態遷移はtoStateMチャネル経由でこのプロセスが行う
proctype TaskStateTransition() {
	mtype:TransitionEvent event;
	short task;

	do 
	:: atomic{toStateM?event,task} -> 
		if 
		:: (change[task].state == passive) && (event == release) -> change[task].state = ready;putQ(task)
		:: (change[task].state == ready) && (event == choose) -> change[task].state = running;
		:: (change[task].state == running) && (event == yield) -> 
			if 
			:: (change[task].togo > 0) -> change[task].state = ready;putQ(task)
			:: else -> change[task].state = passive;
			fi
		:: (change[task].state == running) && (event == wait) -> change[task].state = blocked;change[task].togo = change[task].togo + 1;
		:: (change[task].state == blocked) && (event == notify) -> 
			if 
			:: (change[task].togo > 0) -> change[task].state = ready;putQ(task)
			:: else -> change[task].state = passive;
			fi
		:: else -> skip;
		fi
	od
}
