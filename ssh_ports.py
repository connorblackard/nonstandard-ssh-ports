import requests
import random
import os

def get_ssh_ports():
    # Make an API call and check the response.
    query = 'ssh'
    facets = 'port:65535'
    url = "https://api.shodan.io/shodan/host/count"
    url += f"?key={os.environ['SHODAN_KEY']}&query={query}&facets={facets}"
    r = requests.get(url)

    # Convert the response object to a dictionary.
    response_dict = r.json()

    # Create dictionary for results
    results = {}

    # Process results
    used_ports = []
    for i in response_dict['facets']['port']:
        results[i['value']] = i['count']
        used_ports.append(i['value'])

    # Create lists and sort unused ports according to ranges from RFC 6056
    well_known_ports = []
    registered_ports = []
    dynamic_ports = []

    for i in range (65535):
        if i not in used_ports:
            if i < 1024:
                well_known_ports.append(i)
            elif i < 49152:
                registered_ports.append(i)
            else:
                dynamic_ports.append(i)
            
    # Print most common two ports and three random ports from the each of the IANA port ranges
    for i in list(results.items())[:2]:
        print(f'SSH Port {i[0]}/TCP was found {i[1]} times.')
    top_port = list(results.items())[0][0]
    second_port = list(results.items())[1][0]
    well_known_port = random.choice(well_known_ports)
    registered_port = random.choice(registered_ports)
    dynamic_port = random.choice(dynamic_ports)

    print(f'Well Known Port {well_known_port}/TCP has not been found running SSH.')
    print(f'Registered Port {registered_port}/TCP has not been found running SSH.')
    print(f'Dynamic Port {dynamic_port}/TCP has not been found running SSH.')
    # return ports as list for further uses

if __name__ == __name__:
    print(get_ssh_ports())