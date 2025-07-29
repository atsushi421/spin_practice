byte mutexWait = NOTASK;
byte mutexOwner = NOTASK;
mtype:Status stateMutex = S0;// S0: unlocked,S1: locked

bool pInh = false;// Priority inheritance flag
byte ownerOld;// Original priority of the mutex owner

inline rearrangeQueue(new_pri)
{
	ownerOld = change[mutexOwner].pri;
	change[mutexOwner].pri = new_pri;
	
	// If the mutex owner is in the ready queue, update its priority.
	byte i;
	byte q_len = len(readyQ);
	for (i : 0 .. q_len - 1) {
		byte pri_in_q;byte task_in_q;
		readyQ?pri_in_q,task_in_q;
		if
		:: (task_in_q == mutexOwner) -> 
			readyQ!!new_pri,mutexOwner;
			break
		:: else -> readyQ!pri_in_q,task_in_q;
		fi
	}
}

active proctype Mutex()
{
	mtype:MutexEvents mutex_event;byte task;
	
	do
	:: atomic { toMutex?mutex_event(task) -> 
			if
			:: (stateMutex == S0) -> 
				if
				:: (mutex_event == lock) -> 
					stateMutex = S1;
					mutexOwner = task;
					stable[task].self!ack
				:: else -> assert(false);stable[task].self!ng
				fi
			:: (stateMutex == S1) -> 
				if
				:: ((mutex_event == unlock) && (mutexOwner == task)) -> 
					if
					:: pInh -> 
						// restore the original priority.
						pInh = false;
						change[mutexOwner].pri = ownerOld;
					:: else
					fi
					
					stateMutex = S0;
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
					// Priority inheritance
					if
					:: (change[task].pri < change[mutexOwner].pri) -> 
						printf("Priority inheritance: Task %d inherits priority %d\n",mutexOwner,change[task].pri);
						pInh = true;
						rearrangeQueue(change[task].pri)
					:: else -> skip
					fi
					stable[task].self!ng
				fi
			:: else -> assert(false)
			fi
		}
	od
}
