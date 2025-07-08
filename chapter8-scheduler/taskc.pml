mtype = { S0,S1,S2,S3 };
chan toC = [0] of { mtype };
mtype stateC = S0;

inline BodyOfTaskC ()
{
	if
	:: (stateC == S0) -> stateC = S1
	:: (stateC == S1) -> toMutex!lock(2);toC?M;
		if
		:: (M == ack) -> stateC = S2
		:: else -> skip
		fi
	:: (stateC == S2) -> stateC = S3
	:: (stateC == S3) -> toMutex!unlock(2);toC?M;
		if
		:: (M == ack) -> stateC = S0
		:: else -> skip
		fi
	fi
}

proctype TaskC ()
{
	mtype M;
	do
    :: atomic{ toC?tick -> BodyOfTaskC();toSched!done }
	od
}

