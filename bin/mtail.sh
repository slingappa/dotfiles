#multitail -iw "*.log" 1 -iw /tmp/log.log 1 -iw /tmp/stdout.txt 1 -iw /tmp/stderr.txt 1
#multitail -iw "*.log" 1 -iw /tmp/log.log 1
#multitail $(for i in $(ls *console.log); do printf " -iw %s 1" $i ;done)
#multitail -qs 1 logcat "*.log"
for i in $(seq 1000); do timeout 60 multitail -s 4 -qs 1 logcat  $( for i in $(ls -ltr *.log | tail -n 4 ); do echo $i | grep log ; done); done
