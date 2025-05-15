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

$cache = 360;

header('Cache-Control: max-age='.$cache);
header('Expires: '.gmdate('r', time() + $cache));
header('Pragma: cache');
header('Content-Type: application/json');

$length = isset($_REQUEST['time']) && !empty($_REQUEST['time']) ? intval($_REQUEST['time']) + 1 : 25;
$systemID = $_REQUEST['systemID'];

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

echo json_encode($output);