#include "data_structure.pml"
#include "task_state_transition.pml"
#include "mutex.pml"
#include "task_a.pml"
#include "task_b.pml"
#include "task_c.pml"

#define NEXTDEADLINE(task) stable[task].peri * change[task].n + stable[task].dead - change[task].togo
#define NEXTPERIOD(task) stable[task].peri * (change[task].n + 1)
#define NEWRELEASE(task) stable[task].peri * change[task].n + stable[task].rel

byte tickCount = 0;

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
	:: task == TASK_A_ID -> toA ! tick
	:: task == TASK_B_ID -> toB ! tick
	:: task == TASK_C_ID -> toC ! tick
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
