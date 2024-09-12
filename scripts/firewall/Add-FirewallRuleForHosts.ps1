function Add-FirewallRuleForHosts {
    param (
        [string[]]$Hosts
    )

    foreach ($Host in $Hosts) {
        # Create a firewall rule for outgoing traffic
        New-NetFirewallRule -DisplayName "Block Outbound $Host" -Direction Outbound -Action Block -RemoteAddress $Host -Enabled True

        # Create a firewall rule for incoming traffic
        New-NetFirewallRule -DisplayName "Block Inbound $Host" -Direction Inbound -Action Block -RemoteAddress $Host -Enabled True
    }
}

# List of hosts to block
$hostsToBlock = @(
    "assets.bwbx.io",
    "bwbx.io",
    "securepubads.g.doubleclick.net",
    "g.doubleclick.net",
    "doubleclick.net",
    "vi.ml314.com",
    "ml314.com",
    "onautcatholi.xyz",
    "torrindex.net",
    "exdynsrv.com",
    "ricewaterhou.xyz",
    "js.wpadmngr.com",
    "italarizege.xyz",
    "abservinean.com",
    "a.exdynsrv.com",
    "a.exosrv.com",
    "cdn.engine.spotscenered.info",
    "syndication.exdynsrv.com",
    "d1n3aexzs37q4s.cloudfront.net",
    "iconcardinal.com",
    "cipledecline.buzz",
    "www.viled.cfd"
)

# Call the function to block the listed hosts
Add-FirewallRuleForHosts -Hosts $hostsToBlock
