chan toB = [0] of { mtype:MutexResult };
mtype:Status stateB = S0;
#define TASK_B_ID 1

inline BodyOfTaskB ()
{
	mtype:MutexResult mutex_result;

	if
	:: (stateB == S0) -> stateB = S1
	:: (stateB == S1) -> toMutex!lock(TASK_B_ID);toB?mutex_result;
		if
		:: (mutex_result == ack) -> stateB = S2
		:: else -> skip
		fi
	:: (stateB == S2) -> stateB = S3
	:: (stateB == S3) -> toMutex!unlock(TASK_B_ID);toB?mutex_result;
		if
		:: (mutex_result == ack) -> stateB = S0
		:: else -> skip
		fi
	fi
}

proctype TaskB ()
{
	do
    :: atomic{ toB?tick -> BodyOfTaskB();toSched!done }
	od
}
