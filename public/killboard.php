<?php
$startTime = microtime(true);

if (!session_id()) session_start();

// Check for login & admin permission - else kick
if(!isset($_SESSION['userID'])) {
	http_response_code(403);
	exit();
}

require_once('../config.php');
require_once('../db.inc.php');

$cache = 180;

header('Cache-Control: max-age='.$cache);
header('Expires: '.gmdate('r', time() + $cache));
header('Pragma: cache');
header('Content-Type: application/json');
$systemID = $_REQUEST['systemID'];
// Ensure systemID is provided and is a number
if (!isset($systemID) || !is_numeric($systemID)) {
    echo json_encode(['error' => 'Invalid or missing systemID']);
    exit;
}

// Calculate the timestamp for 24 hours ago
$twentyFourHoursAgo = date('Y-m-d H:i:s', strtotime('-24 hours'));

// Prepare and execute the query
$query = "SELECT * FROM killmails WHERE solar_system_id = :systemID AND killmail_time >= :timeLimit ORDER BY killmail_time DESC";
$stmt = $mysql->prepare($query);
$stmt->bindValue(':systemID', $systemID, PDO::PARAM_INT);
$stmt->bindValue(':timeLimit', $twentyFourHoursAgo, PDO::PARAM_STR);
$stmt->execute();
;
// Fetch all results
$results["kills"] = $stmt->fetchAll(PDO::FETCH_ASSOC);
$results['proccessTime'] = sprintf('%.4f', microtime(true) - $startTime);
$results['SystemID'] = $systemID;
// Return the results as JSON
echo json_encode($results);