from shodan import Shodan
import os

# Setup the Shodan API object
api = Shodan(os.environ['SHODAN_KEY'])

# Submit a scan request for 5 IP Addresses
scan = api.scan(['34.69.91.44', '35.225.68.114', '34.68.121.92', '34.132.231.183', '34.27.202.118'])