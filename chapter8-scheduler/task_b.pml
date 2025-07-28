chan toB = [0] of { mtype:SchedulerEvents };
#define TASK_B_ID 1

inline BodyOfTaskB ()
{
	printf("Processing Task B: n=%d, togo=%d\n", change[TASK_B_ID].n, change[TASK_B_ID].togo);
	skip;
}

proctype TaskB ()
{
	do
    :: atomic{ toB?tick -> BodyOfTaskB();toSched!done }
	od
}
