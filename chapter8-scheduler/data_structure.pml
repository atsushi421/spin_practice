mtype:TransitionEvent = { release,choose,yield,wait,notify };
chan toStateM = [0] of { mtype:TransitionEvent,short }; // short: task index. タスクに遷移イベントを送るためのチャネル
mtype:TaskStatus = { passive,ready,running,blocked };
mtype:SchedulerMutexMessage = { tick,done,ack,ng }; // [tick,done]: scheduler events. [ack,ng]: mutex results.

// Static
typedef TimingProperty {
	byte rel;// relative release time. 固定値。最悪値？
	byte comp;// WCET
	byte dead;// relative deadline
	byte peri;// period
	chan self = [0] of { mtype:SchedulerMutexMessage }; // このタスクがMutexのlockをリクエストした結果を受け取るためのチャネル
}

// Dynamic
typedef TimingStatus {
	byte togo;// residual execution time
	mtype:TaskStatus state = passive;// task status
	byte pri;// priority. The lower the value, the higher the priority.
	byte n;// n-th period
}

#define NUM_TASKS 3

TimingProperty stable[NUM_TASKS];
TimingStatus change[NUM_TASKS];


mtype:MutexEvent = { lock,unlock };
chan toMutex = [0] of { mtype:MutexEvent,byte };


mtype:Status = { S0,S1,S2,S3 };


chan toSched = [0] of { mtype:SchedulerMutexMessage };


chan readyQ = [NUM_TASKS] of { short,short }// task priority, task index
