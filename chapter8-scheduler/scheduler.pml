#include "data_structure.pml"
#include "task_state_transition.pml"
#include "mutex.pml"
#include "task_a.pml"
#include "task_b.pml"
#include "task_c.pml"

byte tickCount = 0; // byteだと足りないかも

#define NEXTDEADLINE(i) stable[i].peri * change[i].n + stable[i].dead - change[i].togo
#define NEXTPERIOD(i) stable[i].peri * (change[i].n + 1)
#define NEWRELEASE(i) stable[i].peri * change[i].n + stable[i].rel

// タスクの時間的な属性値を変更する
inline updateTask() {
	byte I;
	for (I : 0 .. NUM_TASKS - 1) {
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
}

// 仮想的な時間を進める
inline advanceTick() {
	tickCount++;
	// 実行中タスクにtickを送る。to_schedでdoneが来るまで待つ。
}

// Ready状態のタスクからRunning状態にするタスクを選択する
inline selectTask(i) {
	// readyQ ? _, i; // readyQから優先度の高いタスクを選択
	true
}

proctype scheduler(){ 
	short i;

	do 
	:: true -> 
		atomic{updateTask()};
		selectTask(i);
		atomic{advanceTick()}
	od
}

init {
	run TaskStateTransition();
	run Mutex();
	run TaskA();
	run TaskB();
	run TaskC();
	run scheduler();
}
