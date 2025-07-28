chan toA = [0] of { mtype:SchedulerEvents };
mtype:Status stateA = S0;
#define TASK_A_ID 0

inline BodyOfTaskA ()
{
	printf("Processing Task A: n=%d, togo=%d, stateA=%e\n", change[TASK_A_ID].n, change[TASK_A_ID].togo, stateA);
	mtype:MutexResults mutex_result;

	if
	:: (stateA == S0) -> stateA = S1
	:: (stateA == S1) -> toMutex!lock(TASK_A_ID);stable[TASK_A_ID].self?mutex_result;
		if
		:: (mutex_result == ack) -> stateA = S2
		:: else -> skip
		fi
	:: (stateA == S2) -> stateA = S3
	:: (stateA == S3) -> toMutex!unlock(TASK_A_ID);stable[TASK_A_ID].self?mutex_result;
		if
		:: (mutex_result == ack) -> stateA = S0
		:: else -> skip
		fi
	fi
}

proctype TaskA ()
{
	do
    :: atomic{ toA?tick -> BodyOfTaskA();toSched!done }
	od
}
