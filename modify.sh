#!/bin/bash 
source ./config 

function deal_sudoers()
{
    if [ -f "${SUDOERS_PATH}_bak" ]; then \
        echo "存在sudoers "; \
        cp ${SUDOERS_PATH}_bak ${SUDOERS_PATH}; \
    else 
        cp ${SUDOERS_PATH} ${SUDOERS_PATH}_bak
    fi
    echo "sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH}"
    sed -e 's/Defaults\ \ \ \ requiretty/#Defaults    requiretty/g' ${SUDOERS_PATH}_bak > ${SUDOERS_PATH}
}


function deal_vmargs()
{
    if [ -f "${RIAK_VMARGS_BAK}" ]; then \
        echo "存在${RIAK_VMARGS_BAK}"; \
        cp ${RIAK_VMARGS_BAK} ${RIAK_VMARGS}; \
    else \
        cp ${RIAK_VMARGS} ${RIAK_VMARGS_BAK} 
    fi

    echo "sed -e '2 d' ${RIAK_VMARGS_BAK} | \
        sed -e '1 a-name riak@TEMP_IPHOST' > ${RIAK_VMARGS}"

    sed -e '2 d' ${RIAK_VMARGS_BAK} | \
        sed -e '1 a-name riak@TEMP_IPHOST' > ${RIAK_VMARGS}
}

function deal_appconfig()
{
    if [ -f "${RIAK_APPCONFIG_BAK}" ]; then \
        cp ${RIAK_APPCONFIG_BAK} ${RIAK_APPCONFIG}; \
    else \
        cp ${RIAK_APPCONFIG} ${RIAK_APPCONFIG_BAK}; \
    fi
    #{pb, [ {"127.0.0.1", 8087 } ]}
    sed -e 's/127.0.0.1/0.0.0.0/g' ${RIAK_APPCONFIG_BAK} | \
        sed -e 's/riak_kv_bitcask_backend/riak_kv_eleveldb_backend/g' > ${RIAK_APPCONFIG}
}

deal_sudoers
deal_vmargs
deal_appconfig
