Nodes = 1 2 3
test : $(addprefix var/alpine-redis-node,$(Nodes))
	$(Ssh222)1 root@localhost 'redis-cli --cluster create 192.168.222.1:6379 192.168.222.2:6379 192.168.222.3:6379 --cluster-yes'
	
include lib/alpine-base.mk

define DaikerRun
	-fuser -k $@.qcow2 222$1/tcp
	rm -f $@.qcow2
	daiker run -e random -b $<.qcow2 -T 22-222$1 $@.qcow2 &
	$(Wait) $(Ssh222)$1 root@localhost id
	( cat lib/common.m4 && [ ! -f lib/$(@F).m4 ] || cat lib/$(@F).m4 ) | m4 -D m4Hostname=$(@F) -D m4Id=$1 | $(Ssh222)$1 root@localhost
endef
define TmplNode
var/alpine-redis-node$1 : var/alpine-base-redis
	$$(call DaikerRun,$1)
	touch $$@
endef
$(foreach I,$(Nodes),$(eval $(call TmplNode,$I)))

var/alpine-base-redis : var/alpine-base
	$(call DaikerRun,1)
	$(Wait) ! fuser $@.qcow2
	cd var; echo $(@F).qcow2 | daiker convert $(@F).qcow2
	touch $@

clean :
	-fuser -k var/*.qcow2
	rm -rf var
