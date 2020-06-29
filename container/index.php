<?php

use Psr\Http\Message\ServerRequestInterface;

function helloHttp(ServerRequestInterface $request)
{
    $db_socket = getenv('DB_SOCKET', true);
    $db_user = getenv('DB_USER', true);
        
    $link = mysqli_connect('p:localhost', $db_user, NULL, NULL, 0, $db_socket );

    if (!$link) {
        return ('Connect Error (' . mysqli_connect_errno() . ') '
                . mysqli_connect_error());
    }

    if ($result = $link->query("SHOW VARIABLES")) {
        $output = sprintf("Select returned %d rows.\n", $result->num_rows);
        $result->close();
        return $output;
    }     
    
}