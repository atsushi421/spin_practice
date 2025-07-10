chan toA = [0] of { mtype:Message };
mtype:Status stateA = S0;

inline BodyOfTaskA ()
{
	if
	:: (stateA == S0) -> stateA = S1
	:: (stateA == S1) -> toMutex!lock(2);toA?M;
		if
		:: (M == ack) -> stateA = S2
		:: else -> skip
		fi
	:: (stateA == S2) -> stateA = S3
	:: (stateA == S3) -> toMutex!unlock(2);toA?M;
		if
		:: (M == ack) -> stateA = S0
		:: else -> skip
		fi
	fi
}

proctype TaskA ()
{
	mtype:Message M;

	do
    :: atomic{ toA?tick -> BodyOfTaskA();toSched!done }
	od
}
