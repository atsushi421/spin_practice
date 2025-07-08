chan toMutex = [0] of { mtype,byte };
byte mutexWait = NOTASK;
byte mutexOwner = NOTASK;
mtype stateMutex = S0;

proctype Mutex ()
{
	mtype M;byte I;
	do
	:: atomic { toMutex?M(I) -> 
			if
			:: (stateMutex == S0) -> 
				if
				:: (M == lock) -> stateMutex = S1;
					mutexOwner = I;stable[I].self!ack
				:: else -> stable[I].self!ng
				fi
			:: (stateMutex == S1) -> 
				if
				:: ((M == unlock) && (mutexOwner == I)) -> stateMutex = S0;
					if
					:: mutexWait == NOTASK -> skip
					:: else -> toStateM!notify,mutexWait
					fi;
					mutexOwner = NOTASK;mutexWait = NOTASK;
					stable[I].self!ack
				:: (M == lock) -> 
					toStateM!wait,I;mutexWait = I;
					stable[I].self!ng
				fi
			:: else -> assert(false)
			fi
		}
	od
}
