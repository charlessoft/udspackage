RIAK_FILE=riak-1.4.0-1.el5.x86_64.rpm
target:
	echo "help?"
install:
	rpm -ivh  ${RIAK_FILE}
modify:
	bash modify.sh



