mtype:TransitionEvents = { release,choose,yield,wait,notify };
chan toStateM = [0] of { mtype:TransitionEvents,short };// The channel to transition task states. short: task index.

mtype:SchedulerEvents = { tick,done };
chan toSched = [0] of { mtype:SchedulerEvents };

mtype:MutexEvents = { lock,unlock };
chan toMutex = [0] of { mtype:MutexEvents,byte };
mtype:MutexResults = { ack,ng };

mtype:TaskStatus = { passive,ready,running,blocked };

// Static
typedef TimingProperty {
	byte rel;// relative release time
	byte comp;// WCET
	byte dead;// relative deadline
	byte peri;// period
	chan self = [0] of { mtype:MutexResults };// The channel to receive the result of the mutex operation.
}

// Dynamic
typedef TimingStatus {
	byte togo;// residual execution time
	mtype:TaskStatus state = passive;// task status
	byte pri;// priority. The lower the value,the higher the priority.
	byte n;// n-th period
}

#define NUM_TASKS 3

TimingProperty stable[NUM_TASKS];
TimingStatus change[NUM_TASKS];

mtype:Status = { S0,S1,S2,S3 };// For tasks and mutex.

chan readyQ = [NUM_TASKS] of { short,short }// task priority,task index

#define NOTASK 255
