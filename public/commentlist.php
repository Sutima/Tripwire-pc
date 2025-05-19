<?php

// Fetching comments for the comment flares.

$startTime = microtime(true);

if (!session_id()) session_start();

if(!isset($_SESSION['userID'])) {
	http_response_code(403);
	exit();
}

require_once('../config.php');
require_once('../db.inc.php');



header('Content-Type: application/json');

$maskID = 		$_SESSION['mask'];
$characterID = 	$_SESSION['characterID'];
$characterName = $_SESSION['characterName'];
$output = 		null;


$query = 'SELECT systemID, modified from comments WHERE maskID = :maskID';
$stmt = $mysql->prepare($query);
$stmt->bindValue(':maskID', $maskID);
$stmt->execute();
$result = $stmt->fetchAll(PDO::FETCH_CLASS);
$output['commentlist']['commentlist'] = $result;
$output['commentlist']['last_modified'] = date('m/d/Y H:i:s e', $result ? strtotime($result[0]->modified) : time());

$output['proccessTime'] = sprintf('%.4f', microtime(true) - $startTime);
echo json_encode($output);
?>
