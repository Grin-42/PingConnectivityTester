This script will check ping connectivity along the routes to destinations in $routeTargets. 

If there is a switch between the source PC and the router it is a good idea to either add the switch IP or IP of another device connected to the switch in $additionalIPs.

$pingTimeout and $loopBuffer control the sensitivity of the test. For reference cmd ping has a timeout of 5000ms. A timeout of 500ms will give some false positives but is a tradeoff to keep logs from getting stuck too long in one loop and missing critical down information when it matters. 

$loopBuffer set at 1 second is intended to catch short outages, if the network is going down for minutes at a time this should be increased accordingly to reduce logging redundancy. Do not set this to 0 unless you're trying to hit DDOS detection or destroy your hard drive with write operations.

$downCountTreshold is set to 2 to account for normal amounts of packet loss. If one of the IPs never responds or if there are more than 10 or so IPs this can be increased to reduce false positives. This is more useful when it might not be clear when the network goes down. If the outage time is known search for the time and ignore this test entirely.


Additional troubleshooting info:

The standard threshold of packet loss is 4%. There will be a lot of random Down results under normal conditions. The main thing to look for is repeated Down results, particularly if there are multiple consistent down results at the same time.

The first IP in the list is most likely your router and the IP after your router is your ISP gateway.

8.8.8.8 is the public Google DNS server, 1.1.1.1 is the public Cloudflare DNS server.

It is useful to run this from at least two devices on the network simultaneously.
