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

inline getRunningTask(ret_task) {
	atomic {
		byte task;
		for (task : 0 .. NUM_TASKS - 1) {
			if
			:: (change[task].state == running) -> ret_task = task; break
			:: else
			fi
		}
	}
}

inline selectTask(ret_task) {
	byte running_task = NOTASK;
	getRunningTask(running_task);

	if
	:: atomic{ readyQ ? [_, ret_task] -> readyQ ? <_, ret_task>;}
	:: else -> ret_task = NOTASK
	fi

	if
	:: (ret_task == NOTASK && running_task != NOTASK) ->
		ret_task = running_task;
	:: (ret_task != NOTASK && running_task == NOTASK) ->
		readyQ ? _, ret_task;
		toStateM ! choose, ret_task;
	:: else ->
		if
		:: (change[ret_task].pri < change[running_task].pri) -> 
			printf("Preemption occurs: Task %d -> Task %d\n", running_task, ret_task);
			toStateM ! yield, running_task;
			readyQ ? _, ret_task;
			toStateM ! choose, ret_task;
		:: else -> ret_task = running_task
		fi
	fi
}

inline advanceTick(task) {
	if
	:: (task == NOTASK) -> goto advance
	:: else
	fi

	if
	:: task == TASK_A_ID -> toA ! tick
	:: task == TASK_B_ID -> toB ! tick
	:: task == TASK_C_ID -> toC ! tick
	fi

	toSched ? done;
	change[task].togo--;
	if
	:: change[task].togo == 0 -> atomic{printf("%d-th Task %d is completed.\n", change[task].n, task); toStateM ! yield, task}
	:: else
	fi

	advance:
	tickCount++
}

proctype scheduler(byte hyper_period){ 
	short selected_task;

	do 
	:: tickCount < hyper_period -> 
		atomic{updateTask()};
		selectTask(selected_task);
		atomic{advanceTick(selected_task)}
	:: else -> break
	od

	end:
}

init {
	// Tasks are prioritized by RM.
	stable[TASK_A_ID].rel = 0;
	stable[TASK_A_ID].comp = 1;
	stable[TASK_A_ID].dead = 6;
	stable[TASK_A_ID].peri = 6;
	change[TASK_A_ID].pri = 0;
	run TaskA();

	stable[TASK_B_ID].rel = 0;
	stable[TASK_B_ID].comp = 3;
	stable[TASK_B_ID].dead = 8;
	stable[TASK_B_ID].peri = 8;
	change[TASK_B_ID].pri = 1;
	run TaskB();

	stable[TASK_C_ID].rel = 0;
	stable[TASK_C_ID].comp = 4;
	stable[TASK_C_ID].dead = 12;
	stable[TASK_C_ID].peri = 12;
	change[TASK_C_ID].pri = 2;
	run TaskC();
	
	run scheduler(24);
}

ltl priority_inversion {
	[](! (change[TASK_A_ID].state == blocked && change[TASK_B_ID].state == running))
}
