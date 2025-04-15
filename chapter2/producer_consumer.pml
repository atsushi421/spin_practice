#define NFP 2
#define NSP 2

mtype = { F,S,N };
mtype turn = F;
pid who;

inline compare_exchange(turn,expected,new) {
atomic{ (turn == expected) -> turn = new}
}

active [NFP] proctype Producer(){ 
	do 
	:: compare_exchange(turn,F,N);
		who = _pid;
		printf("Producer - %d\n",_pid);
		assert(who == _pid);
		turn = S;
	od
}

active [NSP] proctype Consumer(){ 
	do 
	:: compare_exchange(turn,S,N);
		who = _pid;
		printf("Consumer - %d\n",_pid);
		assert(who == _pid);
		turn = F;
	od
}
