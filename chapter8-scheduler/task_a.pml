chan toA = [0] of { mtype:SchedulerMutexMessage };
mtype:Status stateA = S0;
#define TASK_A_ID 0

inline BodyOfTaskA ()
{
	mtype:SchedulerMutexMessage mutex_result;

	if
	:: (stateA == S0) -> stateA = S1
	:: (stateA == S1) -> toMutex!lock(TASK_A_ID);toA?mutex_result;
		if
		:: (mutex_result == ack) -> stateA = S2
		:: else -> skip
		fi
	:: (stateA == S2) -> stateA = S3
	:: (stateA == S3) -> toMutex!unlock(TASK_A_ID);toA?mutex_result;
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
