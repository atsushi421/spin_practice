chan toA = [0] of { mtype:SchedulerEvents };
#define TASK_A_ID 0

inline BodyOfTaskA ()
{
	printf("Processing Task 0: n=%d, togo=%d\n", change[TASK_A_ID].n, change[TASK_A_ID].togo);
	mtype:MutexResults mutex_result;

	toMutex!lock(TASK_A_ID);stable[TASK_A_ID].self?mutex_result;
	if
	:: (mutex_result == ack) -> toMutex!unlock(TASK_A_ID);stable[TASK_A_ID].self?mutex_result;
	:: else -> skip
	fi
}

proctype TaskA ()
{
	do
    :: atomic{ toA?tick -> BodyOfTaskA();toSched!done }
	od
}
