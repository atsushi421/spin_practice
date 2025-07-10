mtype:TransitionEvent = { release,choose,yield,wait,notify};
chan toStateM = [0] of { mtype:TransitionEvent,short };
mtype:TaskStatus = { passive,ready,running,blocked };
mtype:Message = { ack,ng,tick,done };  // tick,doneは別のmtypeかもしれない

typedef TimingProperty {
	byte rel;// relative release time. 固定値っぽい。最悪値？
	byte comp;// WCET
	byte dead;// relative deadline
	byte peri;// period
	chan self = [0] of { mtype:Message }; // for logical behavior. メッセージサイズは不明
}

typedef TimingStatus {
	byte togo;// residual execution time
	mtype:TaskStatus state;// task status
	byte pri;// priority
	byte n;// n-th period
}

#define NUM_TASKS 3

TimingProperty stable[NUM_TASKS];
TimingStatus change[NUM_TASKS];


mtype:MutexStatus = { lock,unlock };
chan toMutex = [0] of { mtype:MutexStatus,byte };


mtype:Status = { S0,S1,S2,S3 };


chan toSched = [0] of { mtype:Message };


chan readyQ = [NUM_TASKS] of { short,short }
