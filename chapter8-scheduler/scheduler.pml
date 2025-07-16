#include "data_structure.pml"
#include "task_state_transition.pml"
#include "mutex.pml"
#include "task_a.pml"
#include "task_b.pml"
#include "task_c.pml"

byte tickCount = 0;

#define NEXTDEADLINE(i) stable[i].peri * change[i].n + stable[i].dead - change[i].togo
#define NEXTPERIOD(i) stable[i].peri * (change[i].n + 1)
#define NEWRELEASE(i) stable[i].peri * change[i].n + stable[i].rel

inline updateTask() {
	byte task;
	for (task : 0 .. NUM_TASKS - 1) {
		if
		:: (tickCount == 0) -> 
			change[task].n = 0;
			change[task].togo = stable[task].comp // WCETで動く前提
		:: else -> skip
		fi

		if
		:: (NEXTDEADLINE(task) < tickCount) -> 
			printf("deadline violation (%d)\n",task);
			assert(false)
		:: else -> skip
		fi

		if
		:: (NEXTPERIOD(task) == tickCount) -> 
			change[task].n = change[task].n + 1;
			change[task].togo = stable[task].comp // WCETで動く前提
		:: else -> skip
		fi

		if
		:: (NEWRELEASE(task) == tickCount) -> 
			toStateM!release,task
		:: else -> skip
		fi
	}
}

inline selectTask(ret_task) {
	readyQ ? _, ret_task;
	toStateM ! choose, ret_task;
}

inline advanceTick(task) {
	if
	:: task == 0 -> toA ! tick
	:: task == 1 -> toB ! tick
	:: task == 2 -> toC ! tick
	fi

	toSched ? done;
	tickCount++
}

proctype scheduler(){ 
	short selected_task;

	do 
	:: true -> 
		atomic{updateTask()};
		selectTask(selected_task);
		atomic{advanceTick(selected_task)}
	od
}

init {
	run TaskStateTransition();
	run Mutex();
	run TaskA();
	run TaskB();
	run TaskC();
	run scheduler();
}
