# TIP-QNAP-resource-usage-snmp

Telegraf Input Plugin (TIP) to collect resource usage of a QNAP NAS via SNMP.  My use case was to create this script to collect resource usage data of my QNAP NAS to be stored in InfluxDB - visualized in Grafana.  The script could be used for other uses if you just need the json.

I used a snmpwalk application to gather the "oid" (Object Identifier) for the snmp values I was interested in tracking.

The script returns the below output:

```json
{
    "hostname": "<server name>",
    "systemCPU_Usage": 8.40,
    "systemTotalMem": 7860.7,
    "systemFreeMem": 3873.3,
    "systemUptime": 95420670,
    "cpu_Temperature": 34,
    "systemTemperature": 35,
    "hdTemperature_HDD1": 27,
    "hdTemperature_HDD2": 26,
    "hdTemperature_HDD3": 27,
    "hdTemperature_HDD4": 27,
    "sysFanSpeed": 522,
    "sysVolumeTotalSize": 2.67,
    "sysVolumeFreeSize": 775.37
}
```

## Features

* SNMP is used to collect the 
* Output results to json for consumption by Telegraf
* I have limited the result to the condition elements which I was interested in tracking.  Also, I have a 4 bay NAS, hence I wanted to track all 4 drives, but if you have more or less drives, you can update oid.list as appropriate.  Additional SNMP elements could be added/removed to the oid.list file.
* Weather conditions include:
  * CPU Usage (percentage)
  * Total Memory (megabytes)
  * Free Memory (megabytes)
  * System Uptime (milliseconds)
  * CPU Temperature (degrees C)
  * System Temperature (degrees C)
  * HDD 1 Temperature (degrees C)
  * HDD 2 Temperature (degrees C)
  * HDD 3 Temperature (degrees C)
  * HDD 4 Temperature (degrees C)
  * System Fan Speed (revolutions per minute RPM)
  * System Volume Total Size (terabytes *see ^note 1)
  * System Volume Free Sizes (gigabytes *see ^note 1)
* tested / works on various releases of Rasbian as well as Ubuntu
* ^note 1: The "unit" of these measures may be different for you depedning on the size of your NAS

## Prerequisite

Install:

* telegraf (apt-get install telegraf)
* snmp (apt-get install snmp)

## Setup

* download latest release - <https://github.com/ninjaserif/TIP-QNAP-resource-usage-snmp/releases/latest/>

Below is a "one-liner" to download the latest release

```bash
LOCATION=$(curl -s https://api.github.com/repos/ninjaserif/TIP-QNAP-resource-usage-snmp/releases/latest \
| grep "tag_name" \
| awk '{print "https://github.com/ninjaserif/TIP-QNAP-resource-usage-snmp/archive/" substr($2, 2, length($2)-3) ".tar.gz"}') \
; curl -L -o TIP-QNAP-resource-usage-snmp_latest.tar.gz $LOCATION
```

* extract release

```bash
sudo mkdir /usr/local/bin/TIP-QNAP-resource-usage-snmp && sudo tar -xvzf TIP-QNAP-resource-usage-snmp_latest.tar.gz --strip=1 -C /usr/local/bin/TIP-QNAP-resource-usage-snmp
```

* navigate to where you extracted TIP-QNAP-resource-usage-snmp - i.e. `cd /usr/local/bin/TIP-QNAP-resource-usage-snmp/`
* create your own config file `# this is preferred over renaming to avoid wiping if updating to new release`

```bash
cp config-sample.sh config.sh
```

* visit your QNAP web interface and log in.  Once logged in open the "Control Panel" > navigate to "Network & File Services" > "SNMP".  Ensure "Enable SNMP service" is enabled.  My configuration was as follows:
  * Port number = 161
  * SNMP trap level = nothing ticked/enabled
  * SNMP version = SNMP V1/V2
  * Community = `<set your snmp password here>`

* edit config.sh and set your configuration - paste your snmp password into the config for QNAP server

```bash
HOST_IP="<server IP>"               # your QNAP NAS IP
HOST_NAME="<server name>"           # your QNAP name
COMMUNITY="<snmp password>"         # SNMP password
```

* confirm scripts have execute permissions
  * TIP-QNAP-resource-usage-snmp.sh should be executable
  * config.sh should be executable
  * oid.list should be readable

* you may also need to modify the permissions of both the script and config.sh to be owned by the telegraf user:group - i.e. `sudo chown telegraf:telegraf TIP-QNAP-resource-usage-snmp.sh | sudo chown telegraf:telegraf config.sh`

* you may also need to modify the permissions of the directory the script and config.sh are stored to be  - i.e. `sudo chmod 774 /usr/local/bin/TIP-QNAP-resource-usage-snmp`

* add the following to your telegraf.conf

```bash
[[inputs.exec]]
  commands = ["/usr/local/bin/TIP-QNAP-resource-usage-snmp/TIP-QNAP-resource-usage-snmp.sh"]
  timeout = "10s"
  data_format = "json"
  name_suffix = "_QNAPsnmp"
  tag_keys = ["hostname"]
```

## Change log

* 1.0 08-05-2017
  * first release
* 1.0.0 27-09-2020
  * cleaned up for git - set to version 1.0.0
  * use config and location for reference

## -END-
