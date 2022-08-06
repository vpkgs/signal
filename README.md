
## Usage

```v
import sigaction { Siginfo, Ucontext }
import time

fn sig_cb(sig int, siginfo &Siginfo, context &Ucontext) {
	eprintln("From V's fn: signal $sig")
	exit(0)
}
fn main() {
	cb2 := fn (sig int) {
		eprintln("From V's lambda: signal $sig")
		exit(0)
	}

	mut act := sigaction.new_action()
	// act.set_action(sig_cb)
	act.set_handler(cb2)
	act.trap(.hup)?
	act.trap(.int)?
	act.trap(.term)?
	act.trap(.quit)?

	for {
		println('wait a second.')
		time.sleep(1 * time.second)
	}
}
```
