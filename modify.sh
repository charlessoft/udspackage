#!/bin/bash 
source ./config 

function deal()
{
    if [ -f "${RIAK_VMARGS_BAK}" ]; then \
        cp ${RIAK_VMARGS_BAK} ${RIAK_VMARGS}; \
    else \
        cp ${RIAK_VMARGS} ${RIAK_VMARGS_BAK} 
    fi

    sed -e '2 d' ${RIAK_VMARGS_BAK} | \
        sed -e '2 a/-name riak@${IPDEST}' > ${RIAK_VMARGS}
}
function askoverwrite()
{

    echo "存在${RIAK_VMARGS_BAK} 是否重新替换(y|yes|Yes)"
    read ANS
    case $ANS in              
        y|Y|yes|Yes)          
            deal             
            ;;                
        n|N|no|No)            
            exit 0            
            ;;                
    esac
}

if [ -f "${RIAK_VMARGS_BAK}" ]; then \
    echo "ok "; \
    askoverwrite; \
    exit 0;
  else 
      deal;
  fi
