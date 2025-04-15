#define NBUF 2

mtype = { msg,ack };

chan to_sndr = [NBUF] of { mtype,bit };
chan to_rcvr = [NBUF] of { mtype,bit };

active proctype Sender()
{
	bit x,y;
	do 
	:: to_rcvr!msg(x) -> to_sndr?ack(y);
		if 
		:: (x == y) -> x = 1 - x;
		:: else -> skip
		fi
	od
}

active proctype Receiver()
{
	bit y = 1;
	do
	:: to_rcvr?msg(y) -> to_sndr!ack(y);
	:: timeout -> to_sndr!ack(y);
	od
}

active proctype Daemon()
{
	do 
	:: to_rcvr?_,_
	od
}
