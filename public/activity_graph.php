<?php
//***********************************************************
//	File: 		activityData.php
//	Author: 	Daimian
//	Created: 	6/1/2013
//	Modified: 	2/13/2014 - Daimian
//
//	Purpose:	Handles getting activity graph data.
//
//	ToDo:
//		Remove need to revese array
//		Remove need to include zeros
//***********************************************************
$startTime = microtime(true);

if (!session_id()) session_start();

// Check for login & admin permission - else kick
if(!isset($_SESSION['userID'])) {
	http_response_code(403);
	exit();
}

require_once('../config.php');
require_once('../db.inc.php');

$cache = 600;

header('Cache-Control: max-age='.$cache);
header('Expires: '.gmdate('r', time() + $cache));
header('Pragma: cache');
header('Content-Type: application/json');

$length = isset($_REQUEST['time']) && !empty($_REQUEST['time']) ? intval($_REQUEST['time']) +1 : 25;
$systemID = $_REQUEST['systemID'];

//$annotations['2015-12-20 15:00:00'] = Array('label' => 'Downtime', 'text' => 'EVE Downtime');

$query = 'SELECT shipJumps, shipKills, podKills, npcKills, time FROM system_activity WHERE systemID = :systemID ORDER BY time DESC LIMIT :limit';
$stmt = $mysql->prepare($query);
$stmt->bindValue(':systemID', $systemID);
$stmt->bindValue(':limit', $length, PDO::PARAM_INT); // MySQL LIMIT requies this to have an int type sent
$stmt->execute();
$rowCount = $stmt->rowCount();

if ($rowCount === 0) {
    // No data found in ESI pulls, use killmails table
    $output['systemData'] = False;
	$query = '
    SELECT 
        DATE_FORMAT(killmail_time, "%Y-%m-%d %H:00:00") as hour,
        COUNT(CASE WHEN npc = 0 AND victim_ship != 670 THEN 1 END) as ship_kills,
        COUNT(CASE WHEN victim_ship = 670 THEN 1 END) as pod_kills,
        COUNT(CASE WHEN npc = 1 THEN 1 END) as npc_kills
    FROM 
        killmails 
    WHERE 
        solar_system_id = :systemID 
        AND killmail_time >= DATE_SUB(NOW(), INTERVAL :hours HOUR)
    GROUP BY 
        hour
    ORDER BY 
        hour DESC
';

$stmt = $mysql->prepare($query);
$stmt->bindValue(':systemID', $systemID);
$stmt->bindValue(':hours', $length, PDO::PARAM_INT);
$stmt->execute();

$results = $stmt->fetchAll(PDO::FETCH_ASSOC);

$output = [
    'cols' => [
        ['type' => 'string'],
        ['type' => 'number'],
        ['type' => 'number'],
        ['type' => 'number'],
        ['type' => 'number']
    ],
    'rows' => []
];

$now = time();
for ($x = 0; $x < $length; $x++) {
    $hour = date('Y-m-d H:00:00', $now - ($x * 3600));
    $data = [
        ['v' => $x],
        ['v' => 0], // ship jumps (not available in killmails table)
        ['v' => 0], // pod kills
        ['v' => 0], // ship kills
        ['v' => 0]  // npc kills
    ];

    foreach ($results as $row) {
        if ($row['hour'] == $hour) {
            $data[1]['v'] = 0; // ship jumps (not available)
            $data[2]['v'] = (int)$row['pod_kills'];
            $data[3]['v'] = (int)$row['ship_kills'];
            $data[4]['v'] = (int)$row['npc_kills'];
            break;
        }
    }

    $output['rows'][] = ['c' => $data];
}
}
else{
	$output['systemData'] = True;

$output['cols'][] = Array('type' => 'string');
$output['cols'][] = Array('type' => 'number');
$output['cols'][] = Array('type' => 'number');
$output['cols'][] = Array('type' => 'number');
$output['cols'][] = Array('type' => 'number');
#$output['cols'][] = Array('type' => 'string');
#$output['cols'][] = Array('type' => 'string');

$now = time();
$row = $stmt->fetchObject();
for ($x = 0; $x <= $length -1; $x++) {
	$data = null;

/*
	if ($row && isset($annotations[$row->time])) {
		$data[5] = Array('v' => $annotations[$row->time]['label']);
		$data[6] = Array('v' => $annotations[$row->time]['text']);
	} else {
		$data[5] = Array('v' => null);
		$data[6] = Array('v' => null);
	}
*/

	if ($row && date('m/d/Y H', strtotime($row->time)) == date('m/d/Y H', $now - (3600 * $x))) {
		$data[0] = Array('v' => $x);
		$data[1] = Array('v' => (int)$row->shipJumps);
		$data[2] = Array('v' => (int)$row->podKills);
		$data[3] = Array('v' => (int)$row->shipKills);
		$data[4] = Array('v' => (int)$row->npcKills);

		$row = $stmt->fetchObject();
	} else {
		$data[0] = Array('v' => $x);
		$data[1] = Array('v' => 0);
		$data[2] = Array('v' => 0);
		$data[3] = Array('v' => 0);
		$data[4] = Array('v' => 0);
	}

	$output['rows'][]['c'] = $data;
}
}
$output['proccessTime'] = sprintf('%.4f', microtime(true) - $startTime);

echo json_encode($output);
