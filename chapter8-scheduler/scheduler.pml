mtype = { passive,ready,running,blocked };
mtype = { release,select,yield,wait,notify};
chan toStateM = [0] of { mtype,short };

proctype TaskStateTransition() {
	mtype M;short I;
	do 
	:: atomic{toStateM?M,I} -> 
		if 
		:: (change[I].state == passive) && (M == release) -> change[I].state = ready;putQ(I)
		:: (change[I].state == ready) && (M == select) -> change[I].state = running;
		:: (change[I].state == running) && (M == yield) -> 
			if 
			:: (change[I].togo > 0) -> change[I].state = ready;putQ(I)
			:: else -> change[I].state = passive;
			fi
		:: (change[I].state == running) && (M == wait) -> change[I].state = blocked;change[I].togo = change[I].togo + 1;
		:: (change[I].state == blocked) && (M == notify) -> 
			if 
			:: (change[I].togo > 0) -> change[I].state = ready;putQ(I)
			:: else -> change[I].state = passive;
			fi
		:: else -> skip;
		fi
	od
}

typedef TimingProperty {
	byte rel;
	byte comp;
	byte dead;
	byte peri;
	chan self;
}

typedef TimingStatus {
	byte togo;
	mtype status;
	byte pri;
	byte n;
}

TimingProperty stable[3];
TimingStatus change[3];

inline updateTask(i) {
	if
	:: (tickCount == 0) -> 
		change[I].n = 0;
		change[I].togo = stable[I].comp
	:: else -> skip
	fi;
	if
	:: (NEXTDEADLINE(I) < tickCount) -> 
		printf(" deadline violation (%d)\\n",I);
		assert(false)
	:: else -> skip
	fi;
	if
	:: (NEXTPERIOD(I) == tickCount) -> 
		change[I].n = change[I].n + 1;
		change[I].togo = stable[I].comp
	:: else -> skip
	fi;
	if
	:: (NEWRELEASE(I) == tickCount) -> 
		toStateM!release,I
	:: else -> skip
	fi
}

inline advanceTick() {
// 仮想的な時間を進める
}

inline selectTask(i) {
// Ready状態のタスクからRunning状態にするタスクを選択する
}

proctype scheduler(){ 
	short i;
	do 
	:: true -> 
		atomic{updateTask(i)};
		selectTask(i);
		atomic{advanceTick()}
	od
}

chan readyQ [3] of { short,short }
inline putQ(i) {
	readyQ!!change[i].pri,i
}
