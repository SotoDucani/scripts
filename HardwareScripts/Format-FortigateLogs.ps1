<#
.SYNOPSIS
	Parses logs from a fortigate webfilter and removes un-needed information. Written for a Fortigate 60C running 2.XX firmware.
.DESCRIPTION
	This script works through a log file and removes any un-needed information to make it easier to identify traffic patterns. If you wish to delete a section of information, un-comment it. If you wish to keep a piece of information, be sure to keep the section that removes it commented. Do this with a '#' at the beginning of each line to comment it out.
	
	The filename must be manually set in the script itself, not passed as a parameter. It is suggested that you use a different filename for the output so you have a fallback in case you delete something you didn't mean to.

	Basic structure of the script should be in the below format.
	Get-Content "FILENAME" | Foreach-Object {$_ -replace 'TEXT TO SEARCH', 'TEXT TO INPUT'} | Set-Content "FILENAME"
.INPUTS
	A FortiGate logfile must be saved in the same location as this script. The filename is then set in the script itself.
.OUTPUTS
	The input file with the selected portions of the log deleted.
.NOTES
	File Name : Format-FortigateLogs.ps1
	Author : Joshua Herrmann
	Written for : Powershell V3.0
	Version : 1.0
#>

(Get-Content 'FILENAME') |

#log_id=*
#Foreach-Object {$_ -replace ' log_id=[^ ]*', ''} |

#type=*
Foreach-Object {$_ -replace ' type=[^ ]*', ''} |

#subtype=*
Foreach-Object {$_ -replace ' subtype=[^ ]*', ''} |

#pri=*
Foreach-Object {$_ -replace ' pri=[^ ]*', ''} |

#vd=*
Foreach-Object {$_ -replace ' vd=[^ ]*', ''} |

#policyid=*
Foreach-Object {$_ -replace ' policyid=[^ ]*', ''} |

#intf_policyid=*
Foreach-Object {$_ -replace ' intf_policyid=[^ ]*', ''} |

#identidx=*
Foreach-Object {$_ -replace ' identidx=[^ ]*', ''} |

#serial=*
Foreach-Object {$_ -replace ' serial=[^ ]*', ''} |

#user=*
Foreach-Object {$_ -replace ' user=[^ ]*', ''} |

#group=*
Foreach-Object {$_ -replace ' group=[^ ]*', ''} |

#src=*
#Foreach-Object {$_ -replace ' src=[^ ]*', ''} |

#sport=*
Foreach-Object {$_ -replace ' sport=[^ ]*', ''} |

#src_port=*
Foreach-Object {$_ -replace ' src_port=[^ ]*', ''} |

#src_int=*
Foreach-Object {$_ -replace ' src_int=[^ ]*', ''} |

#dst=*
Foreach-Object {$_ -replace ' dst=[^ ]*', ''} |

#dport=*
Foreach-Object {$_ -replace ' dport=[^ ]*', ''} |

#dst_port=*
Foreach-Object {$_ -replace ' dst_port=[^ ]*', ''} |

#dst_int=*
Foreach-Object {$_ -replace ' dst_int=[^ ]*', ''} |

#service=*
Foreach-Object {$_ -replace ' service=[^ ]*', ''} |

#hostname=*
#Foreach-Object {$_ -replace ' hostname=[^ ]*', ''} |

#carrier_ep=*
Foreach-Object {$_ -replace ' carrier_ep=[^ ]*', ''} |

#profiletype=*
Foreach-Object {$_ -replace ' profiletype=[^ ]*', ''} |

#profilegroup=*
Foreach-Object {$_ -replace ' profilegroup=[^ ]*', ''} |

#profile=*
Foreach-Object {$_ -replace ' profile=[^ ]*', ''} |

#status=*
Foreach-Object {$_ -replace ' status=[^ ]*', ''} |

#req_type=*
Foreach-Object {$_ -replace ' req_type=[^ ]*', ''} |

#url=*
#Foreach-Object {$_ -replace ' url=[^ ]*', ''} |

#sent=*
Foreach-Object {$_ -replace ' sent=[^ ]*', ''} |

#rcvd=*
Foreach-Object {$_ -replace ' rcvd=[^ ]*', ''} |

#msg=*
#Foreach-Object {$_ -replace ' msg=[^ ]*', ''} |

#method=*
Foreach-Object {$_ -replace ' method=[^ ]*', ''} |

#class=*
Foreach-Object {$_ -replace ' class=[^ ]*', ''} |

#class_desc=*
Foreach-Object {$_ -replace ' class_desc=[^ ]*', ''} |

#cat=*
#Foreach-Object {$_ -replace ' cat=[^ ]*', ''} |

#cat_desc=*
#Foreach-Object {$_ -replace ' cat_desc=[^ ]*', ''} |


Set-Content 'FILENAME'