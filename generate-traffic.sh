#!/bin/bash

while /bin/true ; do 
  curl -o/dev/null -ks https://mockbin.apps.east.example.com/tracefwd \
    -H 'Content-Type: application/json' \
    -d'[{"url":"http://west.west.svc.cluster.local:8080/tracefwd","method":"GET","headers":{}},{"url":"http://productpage.bookinfo:9080/productpage","method":"GET","headers":{}}]'
  sleep .1
done
