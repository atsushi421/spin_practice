
chan toC = [0] of { mtype:MutexResult };
mtype:Status stateC = S0;
#define TASK_C_ID 2

inline BodyOfTaskC ()
{
	mtype:MutexResult mutex_result;

	if
	:: (stateC == S0) -> stateC = S1
	:: (stateC == S1) -> toMutex!lock(TASK_C_ID);toC?mutex_result;
		if
		:: (mutex_result == ack) -> stateC = S2
		:: else -> skip
		fi
	:: (stateC == S2) -> stateC = S3
	:: (stateC == S3) -> toMutex!unlock(TASK_C_ID);toC?mutex_result;
		if
		:: (mutex_result == ack) -> stateC = S0
		:: else -> skip
		fi
	fi
}

proctype TaskC ()
{
	do
    :: atomic{ toC?tick -> BodyOfTaskC();toSched!done }
	od
}
