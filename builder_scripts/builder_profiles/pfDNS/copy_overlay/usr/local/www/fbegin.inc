<?php

require_once("notices.inc");
/* $Id$ */
	function return_ext_menu($section) {
		global $config;
		$htmltext = "";
		if($config['installedpackages']['menu'] <> "") {
			foreach($config['installedpackages']['menu'] as $menuitem) {
				if($menuitem['section'] != $section) continue;
				if($menuitem['url'] <> "") {
				 	$addresswithport = getenv("HTTP_HOST");
					$colonpos = strpos($addresswithport, ":");
					if ($colonpos !== False){
						//my url is actually just the IP address of the pfsense box
						$myurl = substr($addresswithport, 0, $colonpos);
					}
					else
					{
						$myurl = $addresswithport;
					}

					$description = str_replace('$myurl', $myurl, $menuitem['url']);
				} else {
					$description = '/pkg.php?xml=' . $menuitem['configfile'];
				}
				$htmltext .= '<li><a href="' . $description . ' "class="navlnk">' . $menuitem['name'] . '</a></li>' . "\n";
			}
		}
		return $htmltext;
	}




	/* NOTICE ACKNOWLEDGE CODE by Erik Kristensen */
	if ($_REQUEST['noticeaction'] == 'acknowledge') {
		$notice_id = $_REQUEST['noticeid'];
		close_notice($notice_id);
	}
	/**********************************************/
?>

<div id="wrapper">

	<div id="header">
		<div id="header-left"><a href="index.php" id="status-link"><img src="/themes/<?= $g['theme']; ?>/images/transparent.gif" border="0"></img></a></div>
		<div id="header-right">
			<div class="container">
				<div class="left">webConfigurator</div>
				<div class="right">
<?
				if (are_notices_pending()) {
					$notices = get_notices();

					$requests=array();

					## Get Query Arguments from URL ###
					foreach ($_REQUEST as $key => $value) {
						if ($key != "PHPSESSID")
							$requests[] = $key.'='.$value;
					}
					if(is_array($requests))
						$request_string = implode("&", $requests);

					if(is_array($notices)) {
						foreach ($notices as $key => $value) {
							$date = date("m-d-y H:i:s", $key);
							$noticemsg = str_replace("'", "", $value['notice']);
							$noticemsg = str_replace('"', "", $noticemsg);
							$noticemsg = str_replace("\n", "", $noticemsg);
							$noticemsg = str_replace("<p>", "", $noticemsg);
							$noticemsg = str_replace("<pre>", "", $noticemsg);
							$noticemsg = str_replace("</pre>", "", $noticemsg);
							$noticemsg = str_replace("</p>", "", $noticemsg);
							$noticemsg = str_replace("<br>", "", $noticemsg);
							$extra_args = "";
							if($_GET['xml']) 
								$extraargs="&xml=" . $_GET['xml'];
							if($_POST['xml']) 
								$extraargs="&xml=" . $_POST['xml'];
							if($_GET['id']) 
								$extraargs="&xml=" . $_GET['id'];
							if($_POST['id'])
								$extraargs="&xml=" . $_POST['id'];
							$notice_msgs = '<a href="?noticeaction=acknowledge&noticeid=all' . $extraargs . '">Acknowledge All</a> &nbsp;&nbsp;&nbsp;&nbsp;.:.&nbsp;&nbsp;&nbsp;&nbsp; ';
							if ($value['url']) {
								$notice_msgs .= $date.' - <a href="'.$url.'?'.$request_string.'&noticeaction=acknowledge&noticeid='.$key.'">['.$value['id'].']</a>';
							} else {
								$notice_msgs .= $date.' - <a href="?'.$request_string.'&noticeaction=acknowledge&noticeid='.$key.'">['.$value['id'].']'.$noticemsg.'</a>';
							}
							$notice_msgs .= " &nbsp;&nbsp;&nbsp;&nbsp;.:.&nbsp;&nbsp;&nbsp;&nbsp; ";
						}
					}
?>
					<div id="alerts">
						<script type="text/javascript">
							var content='<div id="marquee-text"><?= $notice_msgs; ?></div>'
						</script>
						<script type="text/javascript" src="/ticker.js"></script>
					</div>
<?
				} else {
?>
					<div id="hostname">
						<? print $config['system']['hostname'] . "." . $config['system']['domain']; ?>
					</div>
<?
				}
?>
				</div>
			</div>
		</div>
	</div> <!-- Header DIV -->
	<div id="content">
		<div id="left">
			<div id="navigation" style="z-index:1000">  
				<ul id="menu">
					<li class="firstdrop">
						<div>System</div>
						<ul class="subdrop">
							<li><a href="/system_advanced.php" class="navlnk">Advanced</a></li>
							<li><a href="/system_firmware.php" class="navlnk">Firmware</a></li>
							<li><a href="/system.php" class="navlnk">General Setup</a></li>
							<li><a href="/wizard.php?xml=setup_wizard.xml" class="navlnk">Setup wizard</a></li>
							<li><a href="/system_routes.php" class="navlnk">Static routes</a></li>
						</ul>
					</li>
					<li class="drop">
						<div>Interfaces</div>
						<ul class="subdrop">
							<?php if (!isset($config['system']['webgui']['noassigninterfaces'])): ?>
							<li><a href="/interfaces_assign.php" class="navlnks">(assign)</a></li>
							<?php endif; ?>
							<li><a href="/interfaces_wan.php" class="navlnk">WAN</a></li>
							<?php echo return_ext_menu("Interfaces"); ?>
						</ul>
					</li>
					<li class="drop">
						<div>Firewall</div>
						<ul class="subdrop">
							<li><a href="/firewall_aliases.php" class="navlnk">Aliases</a></li>
							<li><a href="/firewall_rules.php" class="navlnk">Rules</a></li>
							<li><a href="/firewall_virtual_ip.php" class="navlnk">Virtual IPs</a></li>
							<?php echo return_ext_menu("Firewall"); ?>
						</ul>
					</li>
					<li class="drop">
						<div>DNS</div>
						<ul class="subdrop">
							<?php echo return_ext_menu("Services"); ?>
						</ul>
					</li>
					<li class="drop">
						<div>Status</div>
						<ul class="subdrop">
							<li><a href="/carp_status.php" class="navlnk">CARP (failover)</a></li>
							<li><a href="/status_filter_reload.php" class="navlnk">Filter Reload Status</a></li>
							<li><a href="/status_interfaces.php" class="navlnk">Interfaces</a></li>
							<li><a href="/status_rrd_graph.php" class="navlnk">RRD Graphs</a></li>
							<li><a href="/index.php" class="navlnk">System</a></li>
							<li><a href="/diag_logs.php" class="navlnk">System logs</a></li>
							<li><a href="/status_graph.php?if=wan" class="navlnk">Traffic graph</a></li>
							<?php echo return_ext_menu("Status"); ?>
						</ul>
					</li>
					<li class="lastdrop">
						<div>Diagnostics</div>
						<ul id="diag" class="subdrop">
							<li><a href="/diag_arp.php" class="navlnk">ARP Tables</a></li>
							<li><a href="/diag_backup.php" class="navlnk">Backup/Restore</a></li>
							<li><a href="/diag_defaults.php" class="navlnk">Factory defaults </a></li>
							<li><a href="/halt.php" class="navlnk">Halt system</a></li>
							<li><a href="/diag_ping.php" class="navlnk">Ping</a></li>
							<li><a href="/reboot.php" class="navlnk">Reboot system</a></li>
							<li><a href="/diag_routes.php" class="navlnk">Routes</a></li>
							<li><a href="/diag_dump_states.php" class="navlnk">States</a></li>
							<li><a href="/diag_traceroute.php" class="navlnk">Traceroute</a></li>
							<?php echo return_ext_menu("Diagnostics"); ?>
						</ul>
					</li>
				</ul>
			</div>

		</div> <!-- Left DIV -->

		<div id="right">


<?php
	/* display a top alert bar if need be */
	$need_alert_display = false;
	$found_notices = are_notices_pending();
	if($found_notices == true) {
		$notices = get_notices();
		if(!$notices) {
			$need_alert_display = true;
			$display_text = print_notices() . "<br>";
		}
	}
	if($need_alert_display == true) {
                echo "<div style=\"background-color:#000000\" id=\"roundalert\">";
                echo "<table>";
		echo "<tr><td><font color=\"#ffffff\">";
		echo "&nbsp;&nbsp;<img align=\"middle\" src=\"/top_notification.gif\">&nbsp;&nbsp;&nbsp;";
		echo $display_text;
		echo "</td>";
		echo "</tr>";
		echo "</table>";
		echo "</div>";
	}

?>