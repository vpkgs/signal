module sigaction

#include <signal.h>

fn C.sigaction(sig int, act &C.sigaction, oact &C.sigaction) int
fn C.getppid() int

// union C.__sigaction_u {
// mut:
// 	__sa_handler   voidptr
// 	__sa_sigaction voidptr
// }

struct C.sigaction {
mut:
	// union __sigaction_u __sigaction_u;  /* signal handler */
	// __sigaction_u C.__sigaction_u
	// __sigaction_u.__sa_handler voidptr
	// __sigaction_u.__sa_sigaction voidptr
	sa_handler voidptr
	sa_sigaction voidptr
	sa_mask  C.sigset_t // signal mask to apply
	sa_flags int        // see signal options below
}

pub type Sigaction = C.sigaction

[typedef]
struct C.siginfo_t {
	si_signo  int
	si_code   int
	si_value  C.sigval // union sigval si_value;
	si_errno  int
	si_pid    C.pid_t
	si_uid    C.uid_t
	si_addr   voidptr
	si_status int
	si_band   int
}

pub type Siginfo = C.siginfo_t

[typedef]
struct C.ucontext_t {
	uc_link     &C.ucontext_t
	uc_sigmask  C.sigset_t
	uc_stack    C.stack_t
	uc_mcontext C.mcontext_t
	//  ...
}

pub type Ucontext = C.ucontext_t
pub type SigActionCb = fn (sig int, info &Siginfo, uap &Ucontext)
pub type SigHandlerCb = fn (sig int)

pub enum Sig {
	hup = C.SIGHUP
	int = C.SIGINT
	quit = C.SIGQUIT
	ill = C.SIGILL
	trap = C.SIGTRAP
	abrt = C.SIGABRT
	bus = C.SIGBUS
	fpe = C.SIGFPE
	kill = C.SIGKILL
	usr1 = C.SIGUSR1
	segv = C.SIGSEGV
	usr2 = C.SIGUSR2
	pipe = C.SIGPIPE
	alrm = C.SIGALRM
	term = C.SIGTERM
	// stkflt = C.SIGSTKFLT
	chld = C.SIGCHLD
	cont = C.SIGCONT
	stop = C.SIGSTOP
	tstp = C.SIGTSTP
	ttin = C.SIGTTIN
	ttou = C.SIGTTOU
	urg = C.SIGURG
	xcpu = C.SIGXCPU
	xfsz = C.SIGXFSZ
	vtalrm = C.SIGVTALRM
	prof = C.SIGPROF
	winch = C.SIGWINCH
	io = C.SIGIO
	// pwr = C.SIGPWR
	sys = C.SIGSYS
	// rtmin = C.SIGRTMIN
	// rtmax = C.SIGRTMAX
}

// ```v
// mut act := new_action()
// act.set_action(cb)
// act.trap(.hup)?
// act.trap(.int)?
// act.trap(.term)?
// ```
// ```v
// mut act := new_action()
// act.set_handler(cb)
// act.trap(.hup)?
// act.trap(.int)?
// act.trap(.term)?
// ```
pub fn new_action() Sigaction {
	mut act := Sigaction{}
	unsafe { C.memset(&act, 0, sizeof(act)) }
	return act
}

pub fn (mut sa Sigaction) set_handler(action SigHandlerCb) {
	sa.sa_handler = voidptr(action)
}

pub fn (mut sa Sigaction) set_action(action SigActionCb) {
	// sa.__sigaction_u.__sa_sigaction = voidptr(action)
	sa.sa_sigaction = voidptr(action)
	sa.sa_flags = C.SA_SIGINFO // use `sigaction`, not `handler`
}

pub fn (sa &Sigaction) trap(sig Sig) ? {
	if C.sigaction(int(sig), sa, C.NULL) < 0 {
		return error('sigaction: $C.errno')
	}
}
