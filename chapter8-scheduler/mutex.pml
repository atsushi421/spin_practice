byte mutexWait = NOTASK;
byte mutexOwner = NOTASK;
mtype:Status stateMutex = S0;

active proctype Mutex()
{
	mtype:MutexEvent mutex_event; byte task;

	do
	:: atomic { toMutex?mutex_event(task) -> 
			if
			:: (stateMutex == S0) -> // Unlocked
				if
				:: (mutex_event == lock) -> stateMutex = S1;
					mutexOwner = task;
					stable[task].self!ack
				:: else -> stable[task].self!ng
				fi
			:: (stateMutex == S1) -> // Locked
				if
				:: ((mutex_event == unlock) && (mutexOwner == task)) -> stateMutex = S0;
					if
					:: mutexWait == NOTASK -> skip
					:: else -> toStateM!notify,mutexWait
					fi
					mutexOwner = NOTASK;
					mutexWait = NOTASK;
					stable[task].self!ack
				:: (mutex_event == lock) -> 
					toStateM!wait,task;
					mutexWait = task;
					stable[task].self!ng
				fi
			:: else -> assert(false)
			fi
		}
	od
}
