#define SYNCH 0

mtype = { Get,Put };
chan to_pr = [SYNCH] of { mtype };
chan to_sc = [SYNCH] of { mtype };

proctype Target(chan c){
	do 
	:: c?Get -> c?Put
	od 
}

proctype P(){
	do 
	:: to_pr!Get;to_sc!Get -> progress: skip;to_pr!Put;to_sc!Put
	od
}

proctype Q(){
	do 
	:: to_pr!Get;to_sc!Get -> skip;to_pr!Put;to_sc!Put
	od
}

init {
	atomic{ run Target(to_pr);run Target(to_sc);
		if 
		:: run P();run Q();
		:: run Q();run P();
		fi
	}
}
