while /bin/true ; do
    curl -sk https://mockbin.apps.east.example.com/tracefwd \
        -H 'Content-Type: application/json' \
	-d '[{"url":"http://west.west:8080","method":"GET","headers":{}}]' | \
  	jq -r | jq -r '.response.env.WEST_SERVICE_HOST' | \
  	grep -q '172.40' && echo "remote" || echo "local" 
    sleep .1 
done
