
chan toC = [0] of { mtype:Message };
mtype:Status stateC = S0;

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
	mtype:Message M;

	do
    :: atomic{ toC?tick -> BodyOfTaskC();toSched!done }
	od
}
