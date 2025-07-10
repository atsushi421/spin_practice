chan toB = [0] of { mtype:Message };
mtype:Status stateB = S0;

inline BodyOfTaskB ()
{
	if
	:: (stateB == S0) -> stateB = S1
	:: (stateB == S1) -> toMutex!lock(2);toB?M;
		if
		:: (M == ack) -> stateB = S2
		:: else -> skip
		fi
	:: (stateB == S2) -> stateB = S3
	:: (stateB == S3) -> toMutex!unlock(2);toB?M;
		if
		:: (M == ack) -> stateB = S0
		:: else -> skip
		fi
	fi
}

proctype TaskB ()
{
	mtype:Message M;

	do
    :: atomic{ toB?tick -> BodyOfTaskB();toSched!done }
	od
}
