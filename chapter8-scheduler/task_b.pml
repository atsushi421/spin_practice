chan toB = [0] of { mtype:SchedulerMutexMessage };
#define TASK_B_ID 1

inline BodyOfTaskB ()
{
	skip;
}

proctype TaskB ()
{
	do
    :: atomic{ toB?tick -> BodyOfTaskB();toSched!done }
	od
}
